$(BIN): $(BIN_DEPS)
	$(COMPILE)

run: $(BIN)
	$(BIN) ../input_huge.txt

clean:
	$(CLEAN)
	rm -f solved_input_huge.txt

.PHONY: clean run
