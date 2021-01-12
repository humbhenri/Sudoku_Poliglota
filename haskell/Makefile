GHC=ghc
DEPS=.hs
BIN=sudoku
FLAGS=-O2 --make -w

$(BIN): $(DEPS)
	$(GHC) $(FLAGS) $^ > /dev/null

.PHONY: clean run

clean:
	rm -f solved_input* $(BIN).o $(BIN).hi $(BIN)

run: $(BIN)
	/usr/bin/time -f '%e' ./$(BIN) ../input_huge.txt > /dev/null
