CC=csc
FLAGS=/o /nologo
DEPS=Sudoku.cs
BIN=Sudoku

$(BIN): $(DEPS)
	$(CC) $(FLAGS) $^

.PHONY: clean run
clean:
	rm -f $(BIN).exe solved_input_huge.txt

run: $(BIN)
	/usr/bin/time -f '%e' mono $(BIN).exe ../input_huge.txt > /dev/null
