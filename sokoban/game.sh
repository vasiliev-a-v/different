#!/bin/bash

#~ движок игры

#~ отображаем карту
tput reset
tput cup 0 0
cat $round
tput cup 21 0
echo "Q - выход из игры   | R - перезагрузить раунд"
echo "N - следующий раунд | M - выход в меню" 

tput cup 0 $width
echo "Раунд:" $round_number

#~ функция перехода к следующему раунду
go_next_round()
{
  tput cup 5 $width
  tput setaf 7
  echo -ne "Вы прошли раунд $round_number!"
  sleep 1
  let round_number=round_number+1
  round="round"$round_number".txt"

#~ если файл со следующим раундом существует
  if [ -f "$round" ]; 
  then 
    tput cup 7 $width
    echo -ne "Переходим к раунду $round_number!"
    sleep 1
    exec ./main.sh $round_number
#~ иначе - конец игры, переходит в меню
  else
    tput cup 7 $width 
    echo "Все этапы пройдены."
    tput cup 9 $((width+1))
    echo -ne "Конец игры"
    sleep 1
    exec ./main.sh
  fi
  tput sgr0
}

move_a_man()
{
  #~ старые и новые координаты
  let man_old_xy=$(( x * width + y ))
  let man_new_xy=$(( (x+$1) * width + y+$2 ))

  case "${map[$man_new_xy]}" in 
  $wall_symbol       ) return 0;;
  $home_symbol | "." )  
    buffer_symbol="${map[$man_new_xy]}"
    map[${man_new_xy}]="${map[$man_old_xy]}" 
    map[${man_old_xy}]="$old_symbol"
    old_symbol=$buffer_symbol
      ;;

  $load_symbol       )
    let load_xy=$(( (x+$1+$1) * width + y+$2+$2 ))
    
    #~ если за грузом стена или другой груз
    if [[ "${map[$load_xy]}" == "$wall_symbol" || "${map[$load_xy]}" == "$load_symbol" ]]; then return 0; fi
    
    #~ если за грузом пусто или дом
    if [[ "${map[$load_xy]}" == "." || "${map[$load_xy]}" == "$home_symbol" ]];
    then
      #~ let load_x=x+$1+$1
      #~ let load_y=y+$2+$2
      
      if [ buffer_symbol != "." ]; then buffer_symbol=$buffer2_symbol; fi
      buffer2_symbol="${map[$load_xy]}"
      map[${load_xy}]="${map[$man_new_xy]}"
      map[${man_new_xy}]="${map[$man_old_xy]}" 
      map[${man_old_xy}]="$old_symbol"
      old_symbol=$buffer_symbol
    
      #~ если груз на складе
      if [ $load_xy == $home_xy ]; 
      then
        let loads_in_home=loads_in_home+1
        map[${load_xy}]=$home_symbol
        buffer2_symbol="."
      #~ конец раунда
        if [ $loads_in_home == $number_of_loads ]; then go_next_round; fi
      fi
    
      #~ рисуем груз
      tput cup $((x+$1+$1)) $((y+$2+$2))
      echo -ne "${map[$load_xy]}"\\b
    fi
    ;;
  esac
  
  #~ рисуем за игроком
  tput cup $x $y
  echo -ne "${map[$man_old_xy]}"\\b

  #~ изменяем координаты
  let y=y+$2
  let x=x+$1

  #~ рисуем игрока
  tput cup $x $y
  echo -ne "${map[man_new_xy]}"\\b

  #~ эта строка переносит мигающий курсор 
  tput cup 0 31; echo -ne ""\\b 

}

#~ бесконечный цикл ожидающий нажатия клавиатуры
while true
do
  read -s -n 1

  case "$REPLY" in 
  [\A]   )  [ $x -ne 0  ] && move_a_man -1 0;;
  [\B]   )  [ $x -ne $width ] && move_a_man 1 0;;
  [\D]   )  [ $y -ne 0  ] && move_a_man 0 -1;;
  [\C]   )  [ $y -ne 20 ] && move_a_man 0 1;;
  [rRкК] )  exec ./main.sh $round_number;;
  [mMьЬ] )  exec ./main.sh;;
  [nNтТ] )  go_next_round;;
  [qQйЙ] )  exit 0;; 
  esac 

#~ выводим координаты игрока
  tput cup 2 $((width+7)); echo -ne "  "\\b
  tput cup 2 $((width+18)); echo -ne "  "\\b
  tput cup 2 $((width)); echo -ne "строка="$x\\b
  tput cup 2 $((width+10)); echo -ne "столбец="$y\\b

done
