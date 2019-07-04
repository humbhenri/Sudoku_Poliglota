GO=go
OBJ=sudoku.go

sudoku: $(OBJ)
	$(GO) build $^

.PHONY: clean
clean:
	rm sudoku solved_* -f

run: sudoku
	/usr/bin/time -f '%E' ./sudoku ../input_huge.txt > /dev/null

