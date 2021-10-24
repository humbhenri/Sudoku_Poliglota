#ifndef SUDOKU_H
#define SUDOKU_H

#include <iostream>

const int BOARD_SIZE = 9;

class Sudoku {

 public:
  explicit Sudoku(const std::string &onelinesudoku);
  void solve();
  friend std::ostream& operator<<(std::ostream& os, const Sudoku& dt);
  static void process(std::istream& input, std::ostream& output);

 private:
  bool nextEmpty(int spot[2]);
  bool canPut(const int spot[2], int val);
  int board [BOARD_SIZE][BOARD_SIZE];
};

#endif
