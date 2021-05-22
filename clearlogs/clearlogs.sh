#!/bin/bash
#~ скрипт заходит на устройства и/или сервера
#~ очищает логи (усекает файлы до 0 байт) созданные более 7 дней


#~ path=/projects/bash/clearlogs/prb
path=/var/log
SCRIPT="$(readlink -e "$0")"          #~ полный путь до файла скрипта
MY_DIR="$(dirname $SCRIPT)"           #~ каталог в которой работает скрипт
password=пароль

func_main() {   #~ главная функция - с нее начинает работать программа
  func_read_file "$MY_DIR/config.txt"
  func_clear_logs
  #~ find "${path}" -type f -exec truncate -s 0 {} \;
}


func_read_file() {        #~ читает конфиг устройств в общий массив
  local i; i=0
  local line

  while read line; do
    [[ ${line:0:1} == "#" || ${line:0:2} == "//" ]] && continue #~ удаляет комментарии
    IP[i]=$( echo $line | cut -f1 -d '|' )  #~ столбец IP-адреса
    US[i]=$( echo $line | cut -f2 -d '|' )  #~ столбец IP-адреса
    (( i++ ))
  done < $1
}


func_clear_logs() {  #~ заходит по ssh на устройство или сервер и очищает логи
  for (( i = 0; i < ${#IP[@]}; i++ )); do
    sshpass -p "${password}" ssh "${US[$i]}"@"${IP[$i]}" -p 22 "echo 1 | sudo -S find "${path}" -type f -ctime +7 -exec truncate -s 0 {} \;"
  done
}


func_main	#~ отсюда начинает работать программа
exit 0
