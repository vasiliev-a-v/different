//~ создает ссылку на указанный файл или каталог

#include <gtk/gtk.h>
#include <glib/gprintf.h>
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <stdlib.h>

#define N 3
#define MAX_WORD 256
#define GLADE_FILE "./make_link.glade"

struct mytype {
	char c;
	int i;
} ci, ci2, *pci;

static GtkEntry		*entry[N];
static GtkLabel		*label4;
static GtkImage		*image1;

//~ выбраем файл, на который создадим ссылку
void on_ok_source(GtkFileChooser *choose_file, gpointer data);

//~ если запись в первом поле ввода текста изменилась
void on_file_change(GtkEntry *choose_file, gpointer data);

//~ выбираем каталог
void on_ok_dest(GtkFileChooser *choose_dir, gpointer data);

//~ создаем ссылку
void on_ok_button(GtkWidget *widget, gpointer data);


int main(int argc, char **argv)
{
	struct mytype ci2;
	ci2.i;

	//~ gchar glade_filename[]=;

	GError			*error = NULL;
	GtkBuilder		*builder;
	GtkWindow		*window1;
	GtkButton		*ok_button,
				*ok_source,
				*ok_dest;

	gtk_init(&argc, &argv);
	builder=gtk_builder_new();

	if ( !gtk_builder_add_from_file(builder, GLADE_FILE, &error) ) {
		g_warning( "%s", error->message );
		g_free( error );
		return 1;
	}

	window1   = GTK_WINDOW( gtk_builder_get_object(builder, "window1") );
	ok_button = GTK_BUTTON( gtk_builder_get_object(builder, "ok_button") );
	ok_source = GTK_BUTTON( gtk_builder_get_object(builder, "ok_source") );
	ok_dest   = GTK_BUTTON( gtk_builder_get_object(builder, "ok_dest") );
	entry[0]  = GTK_ENTRY(  gtk_builder_get_object(builder, "entry0") );
	entry[1]  = GTK_ENTRY(  gtk_builder_get_object(builder, "entry1") );
	entry[2]  = GTK_ENTRY(  gtk_builder_get_object(builder, "entry2") );
	label4    = GTK_LABEL(  gtk_builder_get_object(builder, "label4") );
	image1    = GTK_IMAGE(  gtk_builder_get_object(builder, "image1") );

	gtk_builder_connect_signals( builder, NULL );
	g_object_unref( G_OBJECT( builder ) );
	gtk_widget_show( (GtkWidget *) window1 );
	gtk_main();

	return 0;
}


//~ выбраем файл, на который создадим ссылку
void on_ok_source(GtkFileChooser *choose_file, gpointer data)
{
	gchar	*file_name;

	file_name = gtk_file_chooser_get_filename( choose_file );
	gtk_entry_set_text(entry[0], file_name);
	gtk_entry_set_text(entry[2], basename(file_name) );
}


//~ если запись в первом поле ввода текста изменилась
void on_file_change(GtkEntry *choose_file, gpointer data)
{
	gchar *file_name;

	file_name = (gchar *) gtk_entry_get_text( choose_file );
	gtk_entry_set_text(entry[2], basename(file_name) );
}


//~ выбираем каталог
void on_ok_dest(GtkFileChooser *choose_dir, gpointer data)
{
	gchar	*dir_name;

	dir_name = gtk_file_chooser_get_filename( choose_dir );
	dir_name = dirname(dir_name);
	gtk_entry_set_text(entry[1], dir_name);
}


//~ создаем ссылку
void on_ok_button(GtkWidget *widget, gpointer data)
{
	int status;
	gchar	*file_name = NULL,
		*dir_name  = NULL,
		*link_name = NULL,
		dest_name[MAX_INPUT],
		label_text[MAX_WORD],
		image1_icon[MAX_WORD];

	file_name = (gchar *) gtk_entry_get_text( entry[0] );
	dir_name  = (gchar *) gtk_entry_get_text( entry[1] );
	link_name = (gchar *) gtk_entry_get_text( entry[2] );

	//~ создаем адрес ссылки
	strcpy(dest_name, dir_name);
	strcat(dest_name, "/");
	strcat(dest_name, link_name);

	//~ создаем ссылку
	status = symlink(file_name, dest_name);
	//~ создана ли ссылка?
	if ( status == 0 ) {
		strcpy(label_text, "ссылка создана");
		strcpy(image1_icon, "face-smile");
	} else {
		strcpy(label_text, "ссылка не создана");
		strcpy(image1_icon, "face-crying");
	}

	//~ надпись и смайлик
	gtk_label_set_text(label4, label_text);
	gtk_image_set_from_icon_name(image1, image1_icon, GTK_ICON_SIZE_MENU);
}
