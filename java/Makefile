sudoku:
	./gradlew installDist -q

.PHONY: clean

clean:
	./gradlew clean -q

run: sudoku
	/usr/bin/time -f '%e' build/install/java/bin/java ../input_huge.txt > /dev/null
