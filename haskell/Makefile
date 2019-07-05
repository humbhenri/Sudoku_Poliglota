CC=ghc
DEPS=sudoku.hs
BIN=sudoku
FLAGS=-O2 --make -w

$(BIN): $(DEPS)
	$(CC) $(FLAGS) $^ > /dev/null

.PHONY: clean
clean:
	rm -f solved_input* $(BIN).o $(BIN).hi $(BIN)

run: $(BIN)
	/usr/bin/time -f '%e' ./$(BIN) ../input_huge.txt > /dev/null
