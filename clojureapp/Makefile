DEPS=target/uberjar/clojureapp-0.1.0-SNAPSHOT-standalone.jar

sudoku: $(DEPS)
	LEIN_SILENT=true lein uberjar

run: sudoku
	/usr/bin/time -f '%E' java -jar $(DEPS) ../input_huge.txt > /dev/null

.PHONY: clean

clean:
	rm -rf solved_input_huge.txt target/
