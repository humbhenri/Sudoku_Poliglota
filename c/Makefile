CC=gcc
CFLAGS=-O3 -w
OBJ=sudoku.c

sudoku: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

.PHONY: clean
clean:
	rm sudoku solved_* -f

run: sudoku
	/usr/bin/time -f '%E' ./sudoku ../input_huge.txt > /dev/null

