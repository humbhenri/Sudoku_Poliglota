JAR=target/uberjar/clojureapp-0.1.0-SNAPSHOT-standalone.jar

$(JAR):
	LEIN_SILENT=true lein uberjar

run: $(JAR)
	java -jar $(JAR) ../input_huge.txt

clean:
	rm -rf solved_input_huge.txt target/

.PHONY: clean run
