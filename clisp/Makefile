CC=sbcl
DEPS=sudoku.lisp
BIN=sudoku

.PHONY: clean run

$(BIN): $(DEPS)
	$(CC) --load $^ \
	--eval "(sb-ext:save-lisp-and-die #p\"sudoku\" :toplevel #'main :executable t)" > /dev/null

clean:
	rm -f sudoku solved_input_huge.txt

run: $(BIN)
	/usr/bin/time -f '%e' ./$(BIN) ../input_huge.txt > /dev/null

