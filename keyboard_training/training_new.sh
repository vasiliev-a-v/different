#!/bin/bash


#~ KEYBOARD TRAINER


#~ declare global variables
declare -a chs_arr			#~ chars array within characters from input file or random
declare -i G_max_index=10000		#~ max index in "chs_arr" - end of lesson
declare -i G_width=$( tput cols )	#~ global width for text field
declare -i G_height=6			#~ height of rectangle with text
declare -i G_center=$((G_width / 2))	#~ center of G_width
declare -i y=3				#~ position of the text by the Y coordinate
declare -a input_files			#~ array with lessons input files

#~ random chars array
declare -a rnd_az=( a b c d e f g h i j k l m n o p q r s t u v w x i z - " " )
declare -a rnd_09=( 1 2 3 4 5 6 7 8 9 0 4 - = " " )	#~ random chars array
declare -a rnd_chs=( ${rnd_09[@]} ${rnd_az[@]} )

declare is_rnd_chs="no"			#~ if user choosed random chars lesson - "yes"


#~ read file char by char and put them into "chs_arr" array. Arguments: $1 - filename
func_read_file() {
	local i=0			#~ lines array conter (lines index)
	local ch			#~ single char
	local is_space_ch="no"		#~ is char variable contains space (yes or no)?
	local input_filename="$1"

	chs_arr=()			#~ resets the array

	while read -s -n 1 ch; do	#~ read input file char by char
	if [ "$ch" == "" ]; then
		if [ $is_space_ch == "no" ]; then
			chs_arr[$i]=" "
			(( i++ ))
			is_space_ch="yes"
		fi
	else
		chs_arr[$i]=$ch
		is_space_ch="no"
		(( i++ ))
	fi
	done < "$input_filename"
}


#~ print rectangle with G_width ($1) and G_height ($2) chars by arguments
func_print_rectangle() {
	local i=0
	local width=$(( $1 - 2 ))
	local height=$2
	local ln="+"		#~ rectangle's horizontal line

	(( width < 0 )) && return 1

	while (( i < width ))			#~ make horizontal line
	do
		ln="$ln="
		(( i++ ))
	done
	ln="$ln+"

	tput cup $(( y - 1 )) 0			#~ print horizontal line
	echo $ln

	for (( i = y; i < height; i++ )); do	#~ print vertical line
		tput cup $i 0
		echo -n "|"
		func_clear_field $((width - 2)) 1
		tput cup $i $((width + 1))
		echo "|"
	done
	echo $ln
}


#~ print rectangle of spaces. Arguments: $1 - width, $2 - height
func_clear_field() {
	local width=$1		#~ width of rectangle
	local height=$2		#~ height of rectangle
	local h_c=0		#~ height counter
	local w_c=0		#~ width counter
	local spaces=""

	for (( h_c = 0; h_c < height; h_c++ )); do
		for (( w_c = 0; w_c < width; w_c++ )); do
			spaces="$spaces "
		done
		spaces="$spaces\n"	#~ make new line (height)
	done
	echo -e "$spaces"		#~ print rectangle
}


#~ print char or string colored
#~ Arguments: $1 - text, $2 - color, $3 - command after text, f.e. echo
func_print_colored() {
	tput setaf $2
	tput rev
	echo -ne "$1"
	tput sgr 0
	$3
}


#~ function prints line of characters. Arg: $1 - index of the input char from "chs_arr"
func_print_str_ln() {
	local i=$1		#~ index of the input char from "chs_arr"
	local j			#~ need for counting
	local x_line_below	#~ x coordinate for line below input char
	local line_below=""	#~ line below input char
	local line_after=""	#~ line after input char

	if (( i > G_center - 2 )); then		#~ if reached the left edge
		j=$(( i - G_center + 2 ))
		x_line_below=2
	else
		j=0
		x_line_below=$(( G_center - i ))
	fi

	while (( j < i )); do			#~ make line below input char
		line_below="$line_below${chs_arr[$j]}"
		(( j++ ))
	done
	tput cup $((y + 1)) $x_line_below	#~ print line below input char
	echo -n "$line_below"

	tput cup $((y + 1)) $G_center		#~ print input char
	func_print_colored "${chs_arr[$i]}" 3	#~ which user need to type
	
	#~ make and print line after input char, which user need to type
	for (( j = i + 1; j < (i + G_width - G_center - 2); j++ )); do
		line_after="$line_after${chs_arr[$j]}"
	done
	echo -n "$line_after"
}


#~ calc and print user's statistic
func_user_statistic() {
	local i=$1			#~ number of typed chars
	local miss=$2			#~ user's misspelling
	local sd=$3			#~ sd means start date
	local offset=$4			#~ offset from zero index to first value of "chs_arr"
	local score=$(( i - miss ))	#~ user's typing score
	local ld=$(date '+%s')		#~ ld means last date
	local quality			#~ quality of user's typing
	local j=0			#~ counter

	if (( score > 0 )) && (( (ld - sd) > 0 )); then
		statistic=$(echo -e "scale=2; $score / ($ld - $sd) * 60" | bc)
	fi
	if (( miss > 0 )); then	#~ percents of user's typing quality
		quality=$(echo -e "scale=2; $i * 100 / ($i + $miss)" | bc)
	else
		quality=100
	fi
	if [ "$REPLY" == " " ]; then	#~ if user types space bar
		REPLY="SPACE"		#~ will be print "SPACE"
	fi	#~ it's need, because $REPLY is used in array further

	local statistic_array=(		#~ this array makes user's statistic
		"$REPLY"
		$i"/"$((${#chs_arr[@]} + offset - i - 1))
		$miss
		$score
		$quality"%"
		$statistic
		$((ld - sd))
	)

	for str in ${statistic_array[@]}; do		#~ show user's statistic
		tput cup $(( G_height + y + j)) 20	#~ this string erases
		echo -ne "          "			#~ old values from screen
		tput cup $(( G_height + y + j)) 20
		echo $str				#~ prints new values
		(( j++ ))
	done
	#~ echo ${rnd_chs[@]}	#~ need for testing develop
}


#~ choose random chars from "rnd_chs" into "chs_arr"
func_make_rnd_chs_arr() {
	local i				#~ counter index
	local chs_arr_max=0		#~ max index of "chars arr"

	(( ${#chs_arr[@]} != 0 )) && chs_arr_max=$(($1 + ${#chs_arr[@]} - 1))

	for (( i = chs_arr_max; i < (chs_arr_max + 5); i++ )); do
		func_choose_one_rnd_ch $i
	done
	chs_arr[$i+1]=" "			#~ chs_arr must end on SPACE
}


#~ choose one random char from "rnd_chs" array and put it into "chs_arr" array
#~ Arguments: $1 - index of char in chars array, 
func_choose_one_rnd_ch() {
	local i=$1				#~ index of char in chars array
	local ch_ind				#~ index of random char in "chars"
	local r_ch_len=${#rnd_chs[@]}		#~ length of random chars array

	#~ no consecutive symbols
	while true; do				#~ similar do/while in "C"
		ch_ind=$(( $RANDOM % r_ch_len ))
		chs_arr[$i]="${rnd_chs[$ch_ind]}"
		(( i == 0 )) && break
		[ "${chs_arr[$i-1]}" == "${rnd_chs[$ch_ind]}" ] && continue
		break		#~ "else" break
	done
}


#~ if user miss the char
#~ append one more char into "chs_arr" and into "rnd_chs"
func_app_one_more_ch_in_rnd() {
	local missed_char="$2"				#~ char which user miss
	local chs_arr_max=$(($1 + ${#chs_arr[@]}))	#~ max index of "chars arr"

	rnd_chs[${#rnd_chs[@]}]="$missed_char"		#~ append missed char to random chars list
	chs_arr[$chs_arr_max-1]="$missed_char"		#~ append missed char to end of chars array

	func_choose_one_rnd_ch $(($chs_arr_max))
	chs_arr[$chs_arr_max+1]=" "			#~ chs_arr must end on SPACE
}


#~ Arguments: $1 - variable "$i" from "func_check_keyboard"
func_unset_chs_arr() {
	local i=$1
	local offset=0		#~ offset from zero index to first value of "chs_arr"

	if (( i >= G_center )); then
		offset=$((i - G_center))
		unset chs_arr[$offset]
		tput cup 20 20
		echo "| "$offset" | i: "$i" | G_center: "$G_center" | chs_arr: "${#chs_arr[@]}
	fi
	return $offset
}


#~ unfinite loop waiting, when the button will be pressed
func_check_keyboard() {
	local i=0				#~ chars counter
	local miss=0				#~ user's misspelling
	local sd=$(date '+%s')			#~ sd - start date
	local offset=0		#~ offset from zero index to first value of "chs_arr"

	#~ if user has chosen random, then reset "chs_arr" array and fill "chs_arr"
	[ $is_rnd_chs == "yes" ] && chs_arr=() && func_make_rnd_chs_arr

	while [ "${chs_arr[$i]}" != "" ]; do
		( func_print_str_ln $i ) &	#~ work foreground
		read -s -n 1			#~ read user's input
		case "$REPLY" in
			 ) break;;		#~ Ctrl+B - break the lesson
			 ) func_main;;	#~ Ctrl+R - go to main menu
			 ) func_exit_0;;	#~ Ctrl+W - quit the programme
		esac

		wait			#~ waiting "func_print_str_ln" below

		if [ "${chs_arr[$i]}" == "$REPLY" ]; then	#~ if user right
			(( i++ ))
			func_user_statistic $i $miss $sd $offset
			func_unset_chs_arr $i	#~ unset chars in "chs_arr"
			offset=$?		#~ return of "func_unset_chs_arr"
		else				#~ if user wrong
			(( miss++ ))		#~ ups! he did it again! calculate it
			tput flash		#~ and give him some flash to screen
			if [ $is_rnd_chs == "yes" ] && (( i > 0 )); then
				func_app_one_more_ch_in_rnd $offset "${chs_arr[$i]}"
			fi
		fi

		#~ make new random chars in "chs_arr" array
		if [ $is_rnd_chs == "yes" ]
		#~ (( (${#chs_arr[@]}) < (G_center / 2) ));
		then
			func_make_rnd_chs_arr $offset
		fi
	done
}


#~ actions after end of the lesson
func_end_lesson() {
	tput cup $(( G_height + y + 10 )) 0
	func_print_colored "The lesson is end" 6 echo
	func_print_colored "Do you want to play lesson again y/n" 6 echo
	read -s -n 1
	if [ "$REPLY" == "y" ]; then	#~ reloading the lesson
		func_game_interface
		func_check_keyboard
	fi
	func_main
}


#~ nice exit the programme
func_exit_0() {
	tput reset	#~ reset to normal terminal properties
	tput cnorm
	wait		#~ wait when any foreground commands end
	exit 0
}


#~ print caption, rectangle and primary statistic's strings
func_game_interface() {
	local prog_name="KEYBOARD TRAINER"
	local prog_caption="Ctrl+W - quit | Ctrl+R - to main menu | Ctrl + B - break lesson"

	tput reset
	tput civis
	tput cup 0  $((G_center - ${#prog_name} / 2))
	func_print_colored "$prog_name" 6		#~ print the string centered
	tput cup 1  $((G_center - ${#prog_caption} / 2))
	func_print_colored "$prog_caption" 6		#~ print the string centered
	func_print_rectangle $G_width $G_height
	tput cup $((G_height + y - 1)) 0
	echo "
Button pressed:
Chars / left:
Misses:
Score:
Quality:
Chars per min:
Sec. from start:
" &
}


#~ user chooses input file for lesson from list
func_choose_input_file() {
	local line	#~ line contains file
	local i=0	#~ input_files counter

	tput reset
	tput civis
	tput cup 0 0
	func_print_colored "Choose your lesson: Ctrl+W to quit, Ctrl+R to Random lesson" 6 echo
	for line in *".txt"; do
		input_files[$i]=$( basename "$line" )
		echo "${input_files[$i]}"
		(( i++ ))
	done

	is_rnd_chs="no"		#~ reset "random chars" choice
	i=0
	tput cup 1 0
	func_print_colored "${input_files[$i]}" 3

	while true; do
		read -s -n 1
		case "$REPLY" in 
		[\A]	) if (( i > 0 )); then
				tput cup $((i + 1)) 0
				echo "${input_files[$i]}"
				(( i-- ));
				tput cup $((i + 1)) 0
				tput sc
				func_print_colored "${input_files[$i]}" 3
			fi
			;;
		[\B]	) if (( i < (${#input_files[@]} - 1) )); then
				tput cup $((i + 1)) 0
				echo "${input_files[$i]}"
				(( i++ ));
				tput cup $((i + 1)) 0
				func_print_colored "${input_files[$i]}" 3
			fi;;
		""	) break;;
			) func_exit_0;;		#~ Ctrl+W - quit the programme
			) is_rnd_chs="yes"	#~ Ctrl+R - go to main menu
			i=255			#~ magic option - means random
			break;;
		esac
	done
	return $i	#~ returns index in file_array of choosen file
}


#~ main function - from this point the programme starts
func_main() {
	local i			#~ index in file_array that'll return func_choose_input_file

	func_choose_input_file			#~ function returns index
	i=$?					#~ in file_array of choosen file
	((i != 255)) && func_read_file "${input_files[$i]}"
	func_game_interface
	func_check_keyboard
	func_end_lesson
}

func_main	#~ BEGIN (and must be last line)
