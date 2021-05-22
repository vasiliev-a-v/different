#!/bin/bash
#~ это основной файл программы
#~ он подключает другие модули (файлы) программы


source_path="$(dirname $(readlink -e "$0"))"  #~ определяет путь к файлам
                                              #~ для подключения других модулей

#~ если не задан номер раунда, то запускает меню
if [ "$1" != "" ]; then 
  round_number="$1"
else
    source "$source_path/menu.sh"
fi

source "$source_path/header.sh"
source "$source_path/array.sh"
source "$source_path/game.sh"

exit 0
