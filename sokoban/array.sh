#!/bin/bash

#~ записываем игровую карту в массив

#~ текстовый файл в зависимости от раунда
round="round"$round_number".txt"

#~ цикл читает посимвольно файл раунда
while read -s -n1 map[$index]
do
	#~ определяем ширину игровой карты (по верхнему слою)
	if [ $width == 0 ]
	then
		if [ "${map[$index]}" == "`${IFS}`" ]
		then
			let width=index+1
		fi
	fi

	#~ определяем местонахождение игрока
	if [ "${map[$index]}" == "$man_symbol" ]
	then
		let x=$(( index/width ))
		let y=$(( index%width ))
	fi

	#~ определяем местонахождение склада
	if [ "${map[$index]}" == "$home_symbol" ]
	then
		home_xy=$index
	fi

	#~ считаем количество грузов
	if [ "${map[$index]}" == "$load_symbol" ]
	then
		let number_of_loads=number_of_loads+1
	fi

	let index=index+1
done < $round
