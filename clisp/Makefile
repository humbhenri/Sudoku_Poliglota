CC = sbcl
BIN = ./sudoku
BIN_DEPS = sudoku.lisp
COMPILE = $(CC) --load $^ \
	--eval "(sb-ext:save-lisp-and-die \#p\"sudoku\" :toplevel \#'main :executable t)" > /dev/null
CLEAN = rm -f ./sudoku
include ../n.Makefile
