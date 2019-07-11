CC=dmd
CFLAGS=-O -release -inline -boundscheck=off -release
DEPS=source/app.d

sudoku: $(DEPS)
	$(CC) -of=$@ $^ $(CFLAGS)

.PHONY: clean sudoku
clean:
	rm sudoku sudoku.o solved_* -f

run: sudoku
	/usr/bin/time -f '%E' ./sudoku ../input_huge.txt > /dev/null

