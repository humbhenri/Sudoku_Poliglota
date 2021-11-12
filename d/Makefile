CC = dmd
CFLAGS=-O -release -inline -boundscheck=off -release
BIN = ./sudoku
BIN_DEPS = source/app.d
COMPILE = $(CC) -of=$@ $^ $(CFLAGS)
CLEAN = rm -f sudoku.o sudoku
include ../n.Makefile
