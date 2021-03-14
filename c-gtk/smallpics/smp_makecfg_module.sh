func_config_check() {	#~ проверяет наличие и читает конфиг-файл
	CONF_DIR="$HOME"/.config/smallpics		#~ путь к каталогу конфиг-файла
	CONF_FILE="$CONF_DIR"/smallpics.conf	#~ путь к конфиг-файлу
	[ -f "$CONF_FILE" ]     &&  source "$CONF_FILE"  &&  return
	[ -d "$HOME/.config" ]  ||  mkdir  "$HOME/.config"
	[ -d "$CONF_DIR" ]      ||  mkdir  "$CONF_DIR"
	touch "$CONF_FILE"
	func_config_save
}


func_config_save() {	#~ заполняем конфиг-файл
	echo -n > "$CONF_FILE"	#~ обнуляем конфиг
	[ "$SOURCE_DIR" ] || SOURCE_DIR="$HOME"			#~ каталог исходных фото
	echo "SOURCE_DIR=\"$SOURCE_DIR\"" >> "$CONF_FILE"
	[ "$TARGET_DIR" ] || TARGET_DIR="/tmp"			#~ каталог для сжатых фото
	echo "TARGET_DIR=\"$TARGET_DIR\"" >> "$CONF_FILE"
	[ "$QUALITY" ]    || QUALITY="80"				#~ качество фото
	echo "QUALITY=\"$QUALITY\""       >> "$CONF_FILE"
	[ "$IMGSIZE" ]    || IMGSIZE="1280x1024"		#~ размер фото
	echo "IMGSIZE=\"$IMGSIZE\""       >> "$CONF_FILE"
	[ $TO_ZIP ]       || TO_ZIP="0"					#~ зиповать или нет
	echo "TO_ZIP=\"$TO_ZIP\""         >> "$CONF_FILE"
	[ $IMG_LIST ] || IMG_LIST="1280x1024|1024x768|800x600|" #~ список размеров
	echo "IMG_LIST=\"$IMG_LIST\""     >> "$CONF_FILE"
}
