#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <libgen.h>

#define BOARD_SIZE 9

void to_str(int sudoku[BOARD_SIZE][BOARD_SIZE], char *dest);

char* read_entire_file(FILE* file) ;

char* from_str(char *source, int sudoku[BOARD_SIZE][BOARD_SIZE]);

int next_empty(int sudoku[BOARD_SIZE][BOARD_SIZE], int *x, int *y);

int can_put(int sudoku[BOARD_SIZE][BOARD_SIZE], int x, int y, int n);

void solve(int sudoku[BOARD_SIZE][BOARD_SIZE]);

int append_str(char **dest, int buffer_size, char* source);

void load_bar(int step, int total_steps, int resolution, int width);

int main(int argc, char const *argv[])
{
	FILE *f = fopen(argv[1], "r");
	if (!f) {
		printf("Could not open file %s\n", argv[1]);
		exit(EXIT_FAILURE);
	}
    int progress = 0;
    if (argc > 2 && strcmp(argv[2], "-p")) {
        progress = 1;
    }

	/* read entire file into memory */
	char *contents = read_entire_file(f);
	fclose(f);

	/* solve all sudokus */
	struct timeval before;
	gettimeofday (&before, NULL);

	int result_size = 1024;
	char *result = malloc(sizeof(char) * result_size);
	strcpy(result, "");

	char *ptr = contents;
	int total_sudokus = strlen(contents) / (BOARD_SIZE*BOARD_SIZE);
	int sudokus_solved = 0;
	char solved[256];
	do {
		int sudoku[BOARD_SIZE][BOARD_SIZE];
		ptr = from_str(ptr, sudoku);
		solve(sudoku);
		to_str(sudoku, solved);
		result_size = append_str(&result, result_size, solved);
        if (progress) {
            load_bar(++sudokus_solved, total_sudokus, 100, 100);
        }
	} while (*ptr);
	free(contents);

	struct timeval after;
	gettimeofday (&after, NULL);
	long duration = ((after.tv_sec * 1000000 + after.tv_usec) -
		(before.tv_sec * 1000000 + before.tv_usec)) / 1000;

	/* Write to file the solved sudokus */
	char output_name[64];
    char* filename = basename(argv[1]);
	sprintf(output_name, "solved_%s", filename);
	FILE *output = fopen(output_name, "w");
	if (!output) {
		printf("Could not open file %s\n", output_name);
		exit(EXIT_FAILURE);
	}
	fprintf(output, "%s", result);
	free(result);
	fclose(output);

	/* Present time result */
	printf("-- Elapsed time: %ld ms\n", duration);
	return 0;
}

void to_str(int sudoku[BOARD_SIZE][BOARD_SIZE], char *dest) {
	int i, j, len;
	len = 0;
	for (i = 0; i < BOARD_SIZE; i++) {
		for (j = 0; j < BOARD_SIZE; j++) {
			len += sprintf(dest+len, "%d ", sudoku[i][j]);

		}
		len += sprintf(dest+len, "\n");
	}
	sprintf(dest+len, "\n");
}


char* read_entire_file(FILE* file) {
	// get file size
	fseek(file, 0L, SEEK_END);
	int file_len = ftell(file);
	rewind(file);

	// allocate memory
	char *contents = calloc(file_len + 1, sizeof(char));
	if (!contents) {
		printf("Could not allocate memory\n");
		exit(EXIT_FAILURE);
	}

	// read
	fread(contents, file_len, 1, file);
	return contents;
}


char* from_str(char *source, int sudoku[BOARD_SIZE][BOARD_SIZE]) {
	int x, y;
	for (x = 0; x < BOARD_SIZE; x++) {
		for (y = 0; y < BOARD_SIZE; y++) {
			while (*source && !isdigit(*source)) {
				source++;
			}
			if (*source) {
				sudoku[x][y] = *source - '0';
				source++;
			}
		}
	}
	return source;
}


// Return the next spot where is possible to put a number
int next_empty(int sudoku[BOARD_SIZE][BOARD_SIZE], int *x, int *y) {

	int i, j;
	for (i = 0; i < BOARD_SIZE; i++) {
		for (j = 0; j < BOARD_SIZE; j++) {
			if (sudoku[i][j] == 0) {
				*x = i;
				*y = j;
				return 1;
			}
		}
	}
	return 0;
}


int can_put(int sudoku[BOARD_SIZE][BOARD_SIZE], int x, int y, int n) {
	int i, j;
	for (i = 0; i <BOARD_SIZE; i++) {
		// test line
		if (sudoku[i][y] == n) {
			return 0;
		}
		// test column
		if (sudoku[x][i] == n) {
			return 0;
		}
	}

	// test square
	int a = x-(x%3);
	int b = y-(y%3);
	for (i = a; i < a+3; i++) {
		for (j = b; j < b+3; j++) {
			if (sudoku[i][j] == n) {
				return 0;
			}
		}
	}

	return 1;
}


// solve using backtracking
void solve(int sudoku[BOARD_SIZE][BOARD_SIZE]) {
	int x, y, i;
	if (!next_empty(sudoku, &x, &y)) {
		return;
	}
	for (i=1; i<10; i++) {
		if (can_put(sudoku, x, y, i)) {
			sudoku[x][y] = i;
			solve(sudoku);
			int a, b;
			if (!next_empty(sudoku, &a, &b)) {
				// solution found
				return;
			}
		}
	}

	// solution not found, backtrack
	sudoku[x][y] = 0;
}

/* Append a string dest allocated with buffer_size bytes with source */
int append_str(char **dest, int buffer_size, char* source) {
	int dest_size = strlen(*dest);
	int source_size = strlen(source);
	int new_buffer_size = buffer_size;

	// need more space?
	while (new_buffer_size < dest_size + source_size) {
		new_buffer_size *= 2;
	}
	if (new_buffer_size != buffer_size) {
		// make room for the concatenated string
		char *new_dest = (char*) realloc(*dest, new_buffer_size);
		if (!new_dest) {
			printf("Fatal error! Could not reallocate memory\n");
			exit(EXIT_FAILURE);
		}
		*dest = new_dest;
	}

	strcat(*dest, source);

	return new_buffer_size;
}

void load_bar(int step, int total_steps, int resolution, int width) {
	if (total_steps/resolution == 0) return;
	if (step % (total_steps/resolution) != 0) return;
	float ratio = step/(float)total_steps;
    int count = ratio * width;
    printf("%3d%% [", (int)(ratio*100));

    // Show the load bar.
    for (int x=0; x<count; x++)
        printf("=");
    for (int x=count; x<width; ++x)
        printf(" ");
    printf("]\r");
    fflush(stdin);
}
