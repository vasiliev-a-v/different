#!/bin/bash
#~ скрипт создает новый конфиг-файл, если его нет

PROG_DIR="$(dirname "$(readlink -e "$0")")"
source "$PROG_DIR"/smp_makecfg_module.sh


func_main() {
	func_config_check
}


func_main

exit 0
