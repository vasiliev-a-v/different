#!/bin/bash

#~ объявляем переменные

declare -a map; #объявили массив

#~ координаты игрока
x=0; y=0
#~ счетчик символов игровой карты
index=0
#~ ширина игровой карты
width=0
#~ символ стены
wall_symbol="█"
#~ изображение фигурки игрока
man_symbol="☻"
#~ изображение склада, куда складывать груз
home_symbol="۩"
#~ изображение груза
load_symbol="●"
#~ символ пустого места
old_symbol="."
#~ новое положение игрока
man_new_xy=0
#~ буферы программы
buffer_symbol="."
buffer2_symbol="."
#~ номер склада в массиве
home_xy=0
#~ грузов в складе
loads_in_home=0
#~ количество грузов
number_of_loads=0
#~ номер раунда
if [ "$round_number" == "" ]; then round_number=1; fi
