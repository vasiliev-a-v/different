#!/bin/bash

#~ !!! какая-то херня со счетчиком percent !!!

#~ smallpics - Пакетное уменьшение картинок.
#~ создает zip-файл со сжатыми картинками,
#~ Для скрипта необходимы утилита convert из пакета ImageMagick и zip

#~ TODO: загружать варианты размеров из конфига
#~ TODO: сделать, чтобы изменял файлы только в меньшую степень

declare -a argv=( $* ) 	#~ записываем аргументы командной строки в массив argv
PROG_DIR="$(dirname "$(readlink -e "$0")")"


func_main() {			#~ с нее начинает работать программа
	func_declare_global_vars		#~ объявление глобальных переменных
	func_config_check				#~ проверяет наличие и читает конфиг-файл 
	func_check_utils convert zip	#~ проверяем наличие convert и zip

	if (( ${#argv[@]} < 1 )); then	#~ если аргументов командной строки нет
		func_check_utils zenity		#~ проверяем наличие zenity
		func_get_args_by_zenity		#~ взять у юзера аргументы через zenity
	else
		func_check_argv;			#~ вызываем функцию проверки аргументов
	fi
	S_DIRNAME=$( basename "$SOURCE_DIR" )	#~ имя каталога с исходными фото
	TMP_DIR="/tmp"/"$S_DIRNAME"				#~ временный каталог с фото

	func_config_save				#~ сохраняем настройки пользователя
	func_prepare_before_read_pics
	func_read_pics_in_dir "$SOURCE_DIR"
	(( ${#argv[@]} < 1 )) && func_minimize_pics_percent || func_minimize_pics
	func_show_result
	(( TO_ZIP )) && func_to_zip_pics || func_copy_to_target_dir
	func_show_folder_with_result
}


func_declare_global_vars() {		#~ объявление глобальных переменных
	INDEX=0							#~ счетчик (для списка изображений)
	ERR=0							#~ счетчик ошибок конвертирования
									#~ используется в func_minimize_pics
}


func_prepare_before_read_pics() {	#~ подготовка перед чтением func_read_pics_in_dir
	mkdir "$TMP_DIR" 2>/dev/null
}


func_read_pics_in_dir() {	#~ читает каталог с фото. Аргумент $1 - каталог
	local file=""				#~ файлы в каталогах
	local fnd_dirs=( )			#~ массив с найденными каталогами
	local fnd_dirs_tmp=( )		#~ массив каталогов в /tmp
	local dirs_count=0			#~ счетчик каталогов

	for file in "$1/"*; do
		if [ -f "$file" ]; then
			if echo "$file" | grep -E '(JPG|jpg)' 1>/dev/null; then
				FILES_ARR[$INDEX]="$file"
				(( INDEX++ ))
			fi
		elif [ -d "$file" ]; then
			fnd_dirs[${dirs_count}]="$file"
			(( dirs_count++ ))
		fi
	done

	if (( ${#fnd_dirs[@]} > 0 )); then
		local i=0
		for i in $(seq 0 $((${#fnd_dirs[@]}-1))); do
			fnd_dirs_tmp[$i]="${fnd_dirs[$i]##"$SOURCE_DIR"}"
			mkdir "$TMP_DIR${fnd_dirs_tmp[$i]}" 2>/dev/null
			func_read_pics_in_dir "${fnd_dirs[$i]}"
		done
	fi
}


func_minimize_pics_percent() {	#~ создает уменьшенные фото в каталогах $TMP_DIR
	sleep .1	#~ не помню, зачем было нужно...
	(	#~ весь этот хитрый код создан, чтобы показывать проценты процесса
	for ((percent = 0; percent < 100; percent += 100 / INDEX)); do
		#~ путь к файлу заменяем на путь к временной папке
		smallf="$TMP_DIR${FILES_ARR[$i]##"$SOURCE_DIR"}"
		#~ переименовывает файл с названием Фото на photo
		#~ это сделано из-за несовместимости русских кодировок в zip для Windows и Unix систем.
		#~ smallf=$(echo "$smallf" | sed -e "s/Фото/photo/")
		#~ smallf="${smallf//Фото/photo}"
		convert "${FILES_ARR[$i]}" -resize "$IMGSIZE" -quality "$QUALITY" "$smallf"
		echo "#Преобразовано: $percent% \n${FILES_ARR[$i]} \n$smallf"
		echo "$percent"
		(( i++ ))
	done
	echo "#Все файлы обработаны: 100%"
	echo 99		#~ чтобы окно процесса не закрылось сразу
	sleep .5	#~ чтобы пользователь успел прочитать
	) | 
	zenity --progress --percentage=0 --auto-close --auto-kill --width=500 \
	--title="Процесс преобразования" \
	--text="начинаю..."
}


func_minimize_pics() {	#~ создает уменьшенные фото в каталогах $TMP_DIR
	for ((i = 0; i < INDEX; i++)); do
		#~ путь к файлу заменяем на путь к временной папке
		smallf="$TMP_DIR${FILES_ARR[$i]##"$SOURCE_DIR"}"
		#~ переименовывает файл с названием Фото на photo
		#~ это сделано из-за несовместимости русских кодировок в zip для Windows и Unix систем.
		#~ smallf=$(echo "$smallf" | sed -e "s/Фото/photo/")
		#~ smallf="${smallf//Фото/photo}"
		convert "${FILES_ARR[$i]}" -resize "$IMGSIZE" -quality "$QUALITY" "$smallf"
		(( $? != 0 )) && (( ERR++ ))
		echo -e "Преобразовано: \n${FILES_ARR[$i]} \n$smallf"
	done
}


func_show_result() {	#~ выводит окно об окончании работы и ошибках, если есть
	if (( ERR == 0 )); then
		mistakes="без ошибок"
		timeout="--timeout=1"
	else
		mistakes=". Ошибок: $ERR"
		timeout=""
	fi
	zenity --info $timeout --text="Преобразование произведено $mistakes"
}


#~ проверяет наличие необходимых утилит
#~ названия утилит передаются аргументами
func_check_utils() {
	utilites=""	#~ запишется список утилит, которых необходимо установить

	for i in $*; do
		if [[ $(which $i) == "" ]]; then
			utilites="$utilites $i"
		fi
	done

	utilites="${utilites//convert/imagemagick}"

	if [[ "$utilites" != "" ]]; then
		echo "Необходимо установить пакеты: $utilites
		Для этого необходимы права суперпользователя
		Установить (y/n)?
		"
		read -s -n1
		[ "$utilites" == "convert" ] && utilites="imagemagic"	#~ название не совпадает
		if [[ $REPLY == "y" ]]; then
			sudo apt-get install $utilites -y
		else
			echo "Работа программы приостановлена"
		fi
	fi
}


func_show_help() {	#~ отображает подсказку для пользователя
	echo "Использование:"
	echo "-s или --source		- каталог с исходными изображениями"
	echo "-d или --destination	- каталог куда положить zip-архив"
	echo "-q или --quality	- качество изображений 10-100, рекомендуется 60"
	echo "-i или --image-size	- размер изображений 1280x1024|1024x768|800x600"
	echo "-z или --to_zip		- зиповать или нет результат"
	echo "-h или --help		- эта помощь"
	echo "Пример использования:"
	echo "smallpics -s $HOME/pics -d $HOME/download -q 60 -i 1280x1024"
	echo
	exit 0
}


#~ если в командной строке переданы аргументы,
#~ то записываем их значения
func_check_argv() {
	for (( i = 0; i < ${#argv[@]}; i++ )); do
		case ${argv[$i]} in
		"-s" | "--source"	)
			SOURCE_DIR=""	#~ костыль для GTK-обертки на Си
			while [ ${argv[$i+1]:0:1} != "-" ] && (( $i <= ${#argv[@]} ))
			do
				if [ "$SOURCE_DIR" == "" ]; then
					SOURCE_DIR=${argv[$i+1]}
				else
					SOURCE_DIR="$SOURCE_DIR ${argv[$i+1]}"
				fi
				(( i++ ))	#~ потому что аргумент может быть с пробелами
			done;;
		"-d" | "--destination"	)
			TARGET_DIR=""	#~ костыль для GTK-обертки на Си 
			while [[ ${argv[$i+1]:0:1} != "-" ]] && (( $i <= ${#argv[@]} ))
			do
				if [ "$TARGET_DIR" == "" ]; then
					TARGET_DIR=${argv[$i+1]}
				else
					TARGET_DIR="$TARGET_DIR ${argv[$i+1]}"
				fi
				(( i++ ))	#~ потому что аргумент может быть с пробелами
			done
			;;
		"-q" | "--quality"	)
			[ "${argv[$i+1]:0:1}" != "-" ] && QUALITY="${argv[$i+1]}"
			;;
		"-i" | "--image-size"	)
			[ "${argv[$i+1]:0:1}" != "-" ] && IMGSIZE="${argv[$i+1]}"
			;;
		"-z" | "--to_zip"	)
			[ "${argv[$i+1]:0:1}" != "-" ] && TO_ZIP="${argv[$i+1]}"
			;;
		"-h" | "--help"		) func_show_help;;
		esac
	done
	if	[ "$SOURCE_DIR" == "" ] || [ "$TARGET_DIR" == "" ] || \
		[ "$QUALITY"    == "" ] || [ "$IMGSIZE"    == "" ]; then
		echo "Слишком мало аргументов"
		exit 0
	fi
}


func_get_args_by_zenity() {	#~ получить у юзера аргументы через zenity
	func_get_source_dir		#~ запрашиваем исходный каталог
	func_get_target_dir		#~ запрашиваем каталог с результатами
	func_get_quality		#~ запрашиваем качество изображений
	func_get_imgsize		#~ запрашиваем размер изображений
	func_get_to_zip			#~ получаем от пользователя зиповать или нет
}


#~ прерывание пользователем программы через диалоговые окна zenity
#~ $1 - то число, которое вернуло zenity. $2 - Причина прерывания программы
func_check_stop_by_zenity() {
	(( $1 == 0 )) && return
	zenity --info --timeout=1 --text="$2. Работа программы прервана"
	exit 0
}


func_get_source_dir() {	#~ получаем от пользователя каталог с исходными фото
	SOURCE_DIR=$( zenity --file-selection --directory \
	--title="выберите каталог с исходными изображениями" \
	--filename="$SOURCE_DIR/" )
	func_check_stop_by_zenity $? "Каталог с исходными изображениями не выбран"
}


func_get_target_dir() {	#~ получаем от пользователя каталог со сжатыми фото
	TARGET_DIR=$( zenity --file-selection --directory \
	--title="выберите каталог куда положить архив изображений" \
	--filename="$TARGET_DIR/" )
	func_check_stop_by_zenity $? "Каталог назначения не выбран"
}


func_get_quality() {	#~ получаем от пользователя качество изображений
	QUALITY=$( zenity --scale --value=$QUALITY --min-value=10 --max-value=100 \
	--step=5 --text="качество картинки (меньше 60 - ухудшает картинку)" )
	func_check_stop_by_zenity $? "Качество изображений не выбрано"
}


func_get_imgsize() {	#~ получаем от пользователя размер сжатых изображений
	IMGSIZE=$( zenity --list --radiolist --height=230 \
	--title="Выберите размер изображений" \
	--text="Количество точек в изображении по ширине и высоте" \
	--column="@"	--column="размер" \
	'TRUE'			"1280x1024" \
	'FALSE'			"1024x768" \
	'FALSE'			"800x600" )
	func_check_stop_by_zenity $? "Размер изображений не выбран"
}


func_get_to_zip() {	#~ получаем от пользователя зиповать или нет
	TO_ZIP=$( zenity --list --radiolist --print-column=3 --hide-column=3 \
	--height=230 --title="Выберите зиповать или нет" \
	--text="Создать из сжатых фото zip-архив?" \
	--column="@"	--column="zip"				--column="3" \
	'TRUE'			"не создавать zip-архив"	"0" \
	'FALSE'			"создать zip-архив"			"1" )
	func_check_stop_by_zenity $? "Создание zip-архива не выбрано"
}


func_to_zip_pics() {	#~ создает zip-архив со сжатыми картинками
	local from="$(dirname "$TMP_DIR")/$S_DIRNAME.zip"
	local to_dir="$TARGET_DIR"
	local default_dir="$(pwd)"

	cd "$(dirname "$TMP_DIR")"				#~ необходимо для зипования
	zip -r -q -0 -m "$TMP_DIR" "$S_DIRNAME"	#~ создаем zip-архив
	cd "$default_dir"
	if [ "$TARGET_DIR" != "$(dirname "$TMP_DIR")" ]; then
		mv "$from" "$to_dir"		#~ переносим zip-архив в каталог назначения
	fi
}


func_copy_to_target_dir() {	#~ копирует сжатые файлы в каталог назначения
	[ "$TARGET_DIR" == "/tmp" ]      &&  TARGET_DIR="$TARGET_DIR/$S_DIRNAME"
	[ "$TARGET_DIR" != "$TMP_DIR" ]  &&  cp -fR "$TMP_DIR" "$TARGET_DIR"
	(( $? == 0 ))  &&  rm -rf "$TMP_DIR"
}


func_show_folder_with_result() {	#~ открывает юзеру файл-менеджер
	[ -z $(which thunar)   ]  ||  thunar   "$TARGET_DIR"  &&  return
	[ -z $(which pcmanfm)  ]  ||  pcmanfm  "$TARGET_DIR"  &&  return
	[ -z $(which nautilus) ]  ||  nautilus "$TARGET_DIR"  &&  return
}


source "$PROG_DIR"/smp_makecfg_module.sh	#~ подключает модуль создания конфига

func_main	#~ отсюда начинает работать программа
#~ rm -rf /tmp/"$S_DIRNAME"
exit 0
