CXX=g++
CXXFLAGS=-std=c++11 -Wall -pedantic
DEPS = Sudoku.h
OBJ = Sudoku.o main.o 
BIN = sudoku

%.o: %.cpp $(DEPS)
	$(CXX) -c -o $@ $< $(CXXFLAGS)

$(BIN): $(OBJ)
	$(CXX) -o $@ $^ $(CXXFLAGS)

clean:
	rm -f *.o
	rm $(BIN)
