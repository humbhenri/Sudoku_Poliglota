CXX=g++
CXXFLAGS=-std=c++17 -Wall -pedantic -O3
DEPS = Sudoku.h
OBJ = Sudoku.o main.o
BIN = sudoku

%.o: %.cpp $(DEPS)
	$(CXX) -c -o $@ $< $(CXXFLAGS)

$(BIN): $(OBJ)
	$(CXX) -o $@ $^ $(CXXFLAGS) -lstdc++fs 

test: tests.cpp Sudoku.o
	$(CXX) -o $@ $^ -lboost_unit_test_framework $(CXXFLAGS)

.PHONY: clean

clean:
	rm -f *.o $(BIN) test solved_*

run: $(BIN)
	/usr/bin/time -f '%e' ./$(BIN) ../input_huge.txt > /dev/null
