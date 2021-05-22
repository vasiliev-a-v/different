/* скрипт создает на основе входных данных модули на javascript,
 * которые потом можно подключать к телу веб-страницы */

/* порядковый номер модуля, который вставит пользователь */
var module_number = 0;

function make_HTML_to_script(HTML_value, module_number) {
	/* изменяем входные данные с помощью регулярных выражений */
	/* удаляем перенос каретки CR */
	HTML_value = HTML_value.replace(/\r/g, "")
	/* экранируем обратную косую черту */
	HTML_value = HTML_value.replace(/\\/g, "\\\\")
	/* экранируем двойные кавычки */
	HTML_value = HTML_value.replace(/\"/g, "\\\"")
	/* заменяем слово script на выражение scr+ipt */
	HTML_value = HTML_value.replace(/script/g, "scr\" + \"ipt")
	/* если пользователь выбрал "убрать перенос строки" */
	if (my_form.slash_n[0].checked == true) {
		/* удаляем символ переноса строки */
		HTML_value=HTML_value.replace(/\n/g,"")
	}
	else {
		/* иначе оставляем символ */
		HTML_value = HTML_value.replace(/\n/g,"\n")
	}

	/* выходные данные */
	my_form.output_data.value = 'HTML_module' + module_number + ' = "' + HTML_value + '"'

	/* скрипт, который пользователю необходимо вставить в теле HTML-страницы */
	my_form.result_code.value = '<scr' + 'ipt> document.write( HTML_module' + module_number + ' ) </scr' + 'ipt>'
	/* увеличиваем на один и возвращаем в точку вызова функции */
	return ++module_number
}	/* конец функции make_HTML_to_script */
