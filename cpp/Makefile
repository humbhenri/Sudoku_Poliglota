CXX=g++
CXXFLAGS=-std=c++11 -Wall -pedantic
DEPS = Sudoku.h
OBJ = Sudoku.o main.o
BIN = sudoku

%.o: %.cpp $(DEPS)
	$(CXX) -c -o $@ $< $(CXXFLAGS)

$(BIN): $(OBJ)
	$(CXX) -o $@ $^ $(CXXFLAGS) -lboost_system -lboost_filesystem

test: tests.cpp Sudoku.o
	$(CXX) -o $@ $^ -lboost_unit_test_framework $(CXXFLAGS)

clean:
	rm -f *.o
	rm $(BIN)
	rm test
