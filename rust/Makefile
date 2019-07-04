sudoku:
	cargo build --release -q

run: sudoku
	/usr/bin/time -f '%e' ./target/release/sudoku ../input_huge.txt > /dev/null

.PHONY: clean

clean:
	cargo clean
	rm -f solved_input_huge.txt

