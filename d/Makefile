CC = dmd
CFLAGS=-O -release -inline -boundscheck=off -release
BIN = ./sudoku
BIN_DEPS = source/app.d
COMPILE = $(CC) -of=$@ $^ $(CFLAGS)
include ../n.Makefile
