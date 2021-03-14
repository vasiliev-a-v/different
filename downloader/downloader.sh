#!/bin/bash
#~ скрипт производит загрузку сайта для автономной работы
#~ из глобальной сети на N страниц в глубину



func_main() {	#~ главная функция - с нее начинает работать программа
	depth=5
	site=1
	save_dir="/downloads/"

	func_choose_depth
	func_choose_path

	while [ -d "$save_dir"/site$site ]; do
		(( site++ ))
	done
	save_path="$save_dir"/site$site
	echo "создаем каталог $save_path"
	mkdir "$save_path"

	func_choose_link
	url="www."$url

	wget --convert-links -r "$url" --level="$depth" -P "$save_path"
}



func_choose_depth() {	#~ пользователь вводит глубину загрузки
	local text="глубина загрузки по ссылкам (по-умолчанию 5)"
	local title="Введите число"

	depth=$(zenity --text="$text" --title="$title" --entry)
	[ $? != 0 ] && exit 0
	if $(echo -en "$depth" | grep '^[0-9]*$' 1>/dev/null); then
		echo "установлена глубина "$depth
	else
		(( depth = 5 ))
		echo оставлено 5
	fi
}



func_choose_path() {	#~ пользователь выбирает каталог для сохранения сайта
	local title="выберите каталог для сохранения"

	save_dir=$(zenity --title="$title" --file-selection --directory --filename="$save_dir")
	[ $? != 0 ] && exit 0
}



func_choose_link() {	#~ пользователь вводит URL сайта
	local title="введите URL без www."
	local text="введите URL-ссылку для загрузки"

	url=$(zenity --text="$text" --title="$title" --entry)
	[ $? != 0 ] && exit 0
	if [ "$url" == "" ]; then
		url="mail.ru"
	fi
}



func_main

exit 0
