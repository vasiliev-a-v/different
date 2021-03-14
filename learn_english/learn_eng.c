#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#define MAX_INPUT 1024


FILE *open_file(char *filename, char *method) {
	FILE *fp;
	if ((fp = fopen(filename, method)) == NULL) {
		printf("Не могу открыть файл!\n");
		exit(0);
	}
	return fp;
}


int main(int argc, char **argv) {
	int i = 0;
	int c;
	int separator = ':';
	FILE *fp;
	char filename[MAX_INPUT];
	char str[MAX_INPUT];

	if (argc > 1) {
		strcpy(filename, argv[1]);
	} else {
		strcpy(filename, "input_file.txt");
	}

	fp = open_file(filename, "r");

	printf("Type 'Q' to exit the programme\n");
	while (!feof(fp)) {
		fgets(str, MAX_INPUT, fp);
		for (i = 0; str[i] != separator; i++) {
			printf("%c", str[i]);
		}
		system("stty -echo -icanon");
		c = getchar();
		printf("%s", index(str, separator));
		if (c == 'q') {
			break;
		}
	}

	system("stty echo icanon");
	fclose(fp);
	return 0;
}
