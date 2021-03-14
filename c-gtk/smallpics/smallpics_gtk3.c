/* Обертка. Программа создает zip-файл с уменьшенными изображениями
 * взятыми из указанного пользователем каталога
 * Передает данные на smallpics.sh */
#include <gtk/gtk.h>
#include <glib/gprintf.h>	/* для отладочного g_printf */
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <stdlib.h>
#include <stdbool.h>	/* для триггера rewrite */

/* TODO: загружать из конфига размер картинок:
 * для этого список размеров должен загружаться в диалоговое окно */
/* TODO: сделать конфиг-файл отдельным скриптом,
 * чтобы, когда его нет, он создавался */
/* TODO: сделать опцию зиповать или нет РАДИОБАТТОНОМ!! */

#define MAX_WORD 256
#define MAX_STRING 1024
#define GTK_SPN_BUT GTK_SPIN_BUTTON
#define get_obj(obj_name) gtk_builder_get_object(builder, obj_name)

GtkEntry	*entry_srce,
		*entry_dest;
GtkSpinButton	*spin_value;
GtkComboBox	*cmbo_img_siz;
bool		rewrite = 0;
bool		to_zip  = 0;

void  on_ok_source(GtkFileChooser *choose_dir, gpointer data);	/* выбираем исходный каталог */
void  on_ok_dest(GtkFileChooser *choose_dir, gpointer data);	/* выбираем каталог для zip-файла */
int   on_ok_button();	/* при нажатии кнопки OK */
void *get_properties_data(const char *key, char *value);
void  insert_properties_to_window(void);
void insert_properties_to_combo_imgsize(void);

/* при нажатии кнопки "перезаписать Да/Нет" */
void on_rewrite(void) {		/* переключает Да/Нет 1/0 */
	rewrite ^= true;	/* когда 1, то результат 0, когда 0, то 1 */
}


/* при нажатии кнопки "зиповать Да/Нет" */
void on_to_zip(void) {		/* переключает Да/Нет 1/0 */
	to_zip ^= true;		/* когда 1, то результат 0, когда 0, то 1 */
	//~ g_printf("%i\n", to_zip);
}


int main(int argc, char **argv) {
	gchar glade_fname[MAX_WORD];

	GError		*error = NULL;
	GtkBuilder	*builder;
	GtkWidget	*window1;
	GtkButton	*ok_button, *ok_source, *ok_dest, *rewrite_yes;

	//~ создаем полный путь до нашего glade файла
	strcpy(glade_fname, argv[0]);
	//~ dirname(glade_fname);
	//~ glade_fname[strlen(glade_fname)-1]='\0';
	//~ strcat(glade_fname, basename(argv[0]));
	strcat(glade_fname, ".glade");

	gtk_init(&argc, &argv);
	builder = gtk_builder_new();

	if ( !gtk_builder_add_from_file(builder, glade_fname, &error) ) {
		g_warning( "%s", error->message );
		g_free( error );
		return 1;
	}

	window1      = GTK_WIDGET(get_obj("window1"));
	ok_button    = GTK_BUTTON(get_obj("ok_button"));
	ok_source    = GTK_BUTTON(get_obj("ok_source"));
	ok_dest      = GTK_BUTTON(get_obj("ok_dest"));
	entry_dest   = GTK_ENTRY(get_obj("entry_dest"));
	entry_srce   = GTK_ENTRY(get_obj("entry_source"));
	spin_value   = GTK_SPN_BUT(get_obj("pics_quality"));
	cmbo_img_siz = GTK_COMBO_BOX(get_obj("combobox_img_size"));

	insert_properties_to_window();
	insert_properties_to_combo_imgsize();

	gtk_builder_connect_signals( builder, NULL );
	g_object_unref( G_OBJECT( builder ) );
	gtk_widget_show( window1 );
	gtk_main();

	return 0;
}


/* вставляет предыдущие настройки программы в окно */
void insert_properties_to_window(void) {
	char source_dir[MAX_STRING];	/* каталог исходный        */
	char target_dir[MAX_STRING];	/* каталог назначения      */
	char pics_qualy[MAX_WORD];	/* строка качество фото    */
	int  pics_digit;		/* число качество фото     */
	char to_zip_val[MAX_WORD];	/* строка зиповать или нет */

	get_properties_data("SOURCE_DIR", source_dir);
	get_properties_data("TARGET_DIR", target_dir);
	get_properties_data("QUALITY",    pics_qualy);
	get_properties_data("TO_ZIP",     to_zip_val);
	sscanf(pics_qualy, "%i", &pics_digit);
	sscanf(to_zip_val, "%i", &to_zip);
	gtk_spin_button_set_value(spin_value, pics_digit);
	gtk_entry_set_text(entry_srce, source_dir);
	gtk_entry_set_text(entry_dest, target_dir);

}


/* берет данные *value из файла smallpics.conf по ключу *key */
void *get_properties_data(const char *key, char *value) {
	FILE *fp;
	char *p = NULL;
	char s_path[MAX_STRING];
	char *home = NULL;
	char config_file[MAX_STRING];

	home = getenv("HOME");
	sprintf(config_file, "%s/.config/smallpics/smallpics.conf", home);
	if ((fp = fopen(config_file, "r")) != NULL) {
		while ((p = strstr(s_path, key)) == NULL) {
			fgets(s_path, MAX_STRING, fp);
		}
	} else {
		strcpy(value, "");
		return value;
	}
	p = strchr(s_path, '=');	/* строка от знака равно до конца */
	p += 2;				/* удалим равно и двойные кавычки */
	strcpy(s_path, p);
	s_path[strlen(s_path) - 2] = '\0';	/* удаляем вторые кавычки */
	//~ printf("%s\n", s_path);			/* отладочная инфа - удалить */
	strcpy(value, s_path);
	fclose(fp);
	return value;
}


/* читает и вставляет конфиг размеров фото */
void insert_properties_to_combo_imgsize(void) {
	gchar imgsize[MAX_WORD];
	char imglist[MAX_WORD];
	char imgstr[MAX_WORD];
	int i, cnt;

	get_properties_data("IMGSIZE",  imgsize);
	get_properties_data("IMG_LIST", imglist);

	for (i = 0, cnt = 0; i < strlen(imglist); i++) {
		if (imglist[i] == '|') {
			g_printf("%s\n", imgstr);
			gtk_combo_box_text_append_text(cmbo_img_siz, imgstr);
			cnt = 0;
			imgstr[0] = '\0';
		} else {
			imgstr[cnt] = imglist[i];
			imgstr[cnt + 1] = '\0';
			cnt++;
		}
	}

	//~ gtk_combo_box_set_active_id(cmbo_img_siz, imgsize);
	gtk_combo_box_set_active(cmbo_img_siz, 0);
}



/* выбираем исходный каталог с изображениями */
void on_ok_source(GtkFileChooser *choose_dir, gpointer data) {
	gchar *dir_name = gtk_file_chooser_get_filename( choose_dir );
	gtk_entry_set_text(entry_srce, dir_name);
}


/* выбираем каталог для zip-файла */
void on_ok_dest(GtkFileChooser *choose_dir, gpointer data) {
	gchar *dir_name = gtk_file_chooser_get_filename( choose_dir );
	gtk_entry_set_text(entry_dest, dir_name);
}


/* передача аргументов shell-скрипту после нажатия кнопки OK */
int on_ok_button() {
	gchar  run_shell[MAX_STRING] = "";	/* строка вызова программы-скрипта */
	gchar *dir_dest;
	//~ pid_t child;

	gchar *dir_srce = (gchar *) gtk_entry_get_text(entry_srce);	/* исходный каталог */
	if (rewrite) {		/* записываем каталог назначения */
		dir_dest = (gchar *) gtk_entry_get_text(entry_srce);
	} else {
		dir_dest = (gchar *) gtk_entry_get_text(entry_dest);
	}
	gint   img_qual = (gint) gtk_spin_button_get_value(spin_value);	/* качество изображений */
	gchar *img_siz  = gtk_combo_box_get_active_id(cmbo_img_siz);	/* размер изображений */

	if (strcasecmp(dir_srce, "") == 0) return 0;	/* если каталог не выбран */
	if (strcasecmp(dir_dest, "") == 0) return 0;	/* если каталог не выбран */

	/* sprintf(run_shell, "-s %s -d %s -q %i -i %s -z %i", */
	sprintf(run_shell, "exec ./smallpics.sh -s %s -d %s -q %i -i %s -z %i",
		dir_srce, dir_dest, img_qual, img_siz, to_zip);

	system(run_shell);
	gtk_main_quit();

	//~ if (!(child = fork())) {
		//~ execl("./smallpics.sh", "./smallpics.sh", run_shell, NULL);
	//~ } else {
		//~ /* TODO: вставить wait !!! */
		//~ gtk_main_quit();
	//~ }
	return 0;
}



