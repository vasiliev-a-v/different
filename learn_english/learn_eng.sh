#!/bin/bash


#~ this programme scaned lines from an input file and show them to user line by line
#~ first part - before sign ":" and then (after any button pressed) - the shank of line


#~ declare global variables
declare -a lines				#~ array with word lines
declare def_inp_fname="input_file.txt"	#~ the name of default input file
declare new_inp_fname				#~ the name of new input file
declare inp_fname="$def_inp_fname"		#~ the name of input file


#~ get command line options
[ -f "$1" ] && new_inp_fname="$1"		#~ name of file from command line
[ !"$1" ] && new_inp_fname="new_input_file.txt"


#~ append new line into lines array
#~ argument $1 - new line (word, which user don't know)
func_append_word_into_array() {
	local lines_len=${#lines[@]}		#~ count length of lines array
	local append_word="$1"			#~ which word we need to append

	lines[$lines_len]="$append_word"	#~ append word into end of array
	echo "$append_word" >>"new_input_file.txt"
	echo "добавлено: $append_word"
}


#~ show to user new words and wait user type any button
func_user_input_lines() {
	local i					#~ "lines" array index
	local prev_word				#~ previos line index value
	local eng_line				#~ english part of line
	local quantity				#~ quantity (number) of lines

	tput reset
	echo "Q - exit | R - don't know the word | B - don't know previos word"

	while true; do				#~ infinite loop
		quantity=${#lines[@]}
		[ $quantity == 0 ] && return 0		#~ if "lines" array is empty
		echo "quantity="$quantity
		i=$(( $RANDOM % $quantity ))		#~ make random "lines" array index
		#~ take characters before symbol ":" - there are english words
		eng_line=$( echo "${lines[$i]}" | awk -F ':' '{print $1}' )
		echo -ne "$eng_line"			#~ show english words
		read -s -n1				#~ press any key
		echo -ne ${lines[$i]#$eng_line}"\t	"	#~ show translate part of line
		case "$REPLY" in
			[qQ] ) func_nice_exit;;		#~ if "Q" is pressed - quit the loop
			[rR] ) func_append_word_into_array "${lines[$i]}";;
			[bB] ) func_append_word_into_array "$prev_word";;
		esac
		prev_word="${lines[$i]}"

		#~ decrement "lines" array by one line (one index value)
		lines[$i]="${lines[${#lines[@]}-1]}"
		unset lines[${#lines[@]}-1]
	done
}


#~ read input file line by line into $lines array
func_read_file() {
	local i=0	#~ lines array conter (lines index)
	local line	#~ single line
	local inp_fname="$1"

	while read line; do		#~ read input file line by line
		[ "$line" == "" ] || [ "$line" == ":" ] && continue
		lines[$i]=$line
		(( i++ ))
	done < $inp_fname
}


#~ ask user which file to load
func_default_or_new_input_file() {
	echo "Default (press any key) or new (press N) input file? Clear new file - C"
	read -s -n 1
	case "$REPLY" in
	[qQйЙ]	) func_nice_exit;;
	[nNтТ]	) [ -f "$new_inp_fname" ] && inp_fname="$new_inp_fname";;
	[cCсС]	) [ -f "$new_inp_fname" ] && rm "$new_inp_fname" && touch "$new_inp_fname";;
	*	) inp_fname="$def_inp_fname"
	esac
	func_print_loadind_animation
}


#~ showes simple animation of loading file
func_print_loadind_animation() {
	local i		#~ counter for loop

	echo -n $inp_fname" is loading"
	for (( i = 1; i < 10; i++ )); do
		echo -n "."
		sleep .2
		if ((i % 3 == 0)); then
			echo -ne "\b\b\b"
			echo -ne "   "
			echo -ne "\b\b\b"
		fi
	done
	echo
}


#~ aks user to repeat or quit out of the programme
func_end_of_programme() {
	echo "Repeat (press any key) or quit out (press Q) of the programme?"
	read -s -n 1
	if [ "$REPLY" == "q" ]; then
		func_nice_exit
	else
		return 0
	fi
}


#~ make nice exit of the programme
func_nice_exit() {
	echo			#~ just print empty line
	tput cnorm		#~ normal terminal properties (with cursor)
	exit 0
}


#~ main function - begin to work
func_main() {
	while true; do
		tput reset
		tput civis
		func_default_or_new_input_file		#~ ask user about input file
		func_read_file "$inp_fname"		#~ read input file into $lines array
		func_user_input_lines			#~ user input words
		func_end_of_programme			#~ when input words have finished
	done
}


func_main	#~ call the function and begin to work
