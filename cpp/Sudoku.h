#ifndef SUDOKU_H
#define SUDOKU_H

#include <iostream>

const int BOARD_SIZE = 9;

class Sudoku {

 public:
  Sudoku(const std::string &onelinesudoku);
  void solve();
  friend std::ostream& operator<<(std::ostream& os, const Sudoku& dt);

 private:
  bool nextEmpty(int spot[2]);
  bool canPut(int spot[2], int val);
  int board [BOARD_SIZE][BOARD_SIZE];
};

#endif
