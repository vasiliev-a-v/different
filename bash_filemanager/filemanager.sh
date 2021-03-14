#!/bin/bash

#~ файловый менеджер

declare -i x
declare -a ls_array
declare -i index=0

cd /

#~ читает каталог и записывает в массив
list_files()
{
	x=1
	unset ls_array
	index=0
	tput cup 0 0
	tput reset

#~ старая версия
	#~ for files in `ls $(pwd) -a -1`
	for files in *
	do
		ls_array[${index}]="$files"
		((index+=1))
		echo "$index ${ls_array[((index-1))]}"
	done 
}

#~ двигает курсор
move_cursor()
{
	tput cup $x 0
	echo -ne "$((x+1)) ${ls_array[$x]}"
	((x+=$1))
	tput cup $x 0
	tput rev
	echo -ne "$((x+1)) ${ls_array[$x]}"
	tput sgr0
}

list_files

#~ бесконечный цикл, читающий ввод
while true
do
	read -s -n 1
	case "$REPLY" in
	[\A]   )	[[ $x > 0 ]] && move_cursor -1 0;;
	[\B]   )	[[ $x -lt $((${#ls_array[*]}-1)) ]] && move_cursor 1 0;;
	"" )	
	tput reset; 
	echo "${ls_array[$x]}"; 
	cd "${ls_array[$x]}"; 
	sleep 1
	ls; 
	sleep 1; 
	list_files
	;;
	[qQйЙ] )	exit 0;; 
	esac
done
