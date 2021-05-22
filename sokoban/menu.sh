#!/bin/bash

#~ файл главного меню программы

tput reset
tput setaf 3
tput rev
tput cup 1 5
echo "SOKOBAN"
sleep 1
tput sgr0
tput cup 5 0
echo -e "Press \"S\" to play\v"
echo "Press \"R\" to reload"
echo "Press \"Q\" to exit"

while true
do
read -s -n 1
case "$REPLY" in 
  [sSыЫ] ) break;;
  [rRкК] )  exec ./main.sh;;
  [nNтТ] )  true ;;
  [qQйЙ] )  exit 0;; 
esac 
done
