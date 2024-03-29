#include "Sudoku.h"
#include <algorithm>
#include <iostream>
#include <iomanip>
#include <iterator>
#include <vector>

Sudoku::Sudoku(const std::string &data) {
  int i = 0, j = 0;
	for (auto it : data) {
		if (isdigit(it)) {
			board[i][j] = it - 48;
		}
    if (j == BOARD_SIZE - 1) {
      i += 1 % BOARD_SIZE;
      j = 0;
    } else {
      j += 1 % BOARD_SIZE;
    }
	}
}

void Sudoku::solve() {
  int spot[] = {0, 0};
  if (!nextEmpty(spot)) {
		return;
	}

	for (int i=1; i<10; i++) {
		if (canPut(spot, i)) {
			board[spot[0]][spot[1]] = i;
			solve();
			int _[] = {0, 0};
			if (!nextEmpty(_)) {
				return;
			}
		}
	}
  board[spot[0]][spot[1]] = 0; // solution not found, backtrack
}

bool Sudoku::nextEmpty(int spot[2]) {
	for (int i=0; i<BOARD_SIZE; i++) {
		for (int j=0; j<BOARD_SIZE; j++) {
			if (board[i][j] == 0) {
				spot[0] = i;
				spot[1] = j;
				return true;
			}
		}
	}
	return false;
}

bool Sudoku::canPut(const int spot[2], int val) {
	int x = spot[0];
	int y = spot[1];
	for (int i=0; i<BOARD_SIZE; i++) {
    // test row
		if (board[i][y] == val) {
			return false;
		}
    // test column
		if (board[x][i] == val) {
			return false;
		}
	}
  // test square
	int a = x-(x%3);
	int b = y-(y%3);
	for (int i=a; i<a+3; i++) {
		for (int j=b; j<b+3; j++) {
			if (board[i][j] == val) {
				return false;
			}
		}
	}
	return true;
}

std::ostream& operator<<(std::ostream& os, const Sudoku& sudoku) {
  for (int i=0; i<BOARD_SIZE; i++) {
		for (int j=0; j<BOARD_SIZE; j++) {
			os << sudoku.board[i][j] << " ";
		}
		os << "\n";
	}
	os << "\n";
  return os;
}

void progress_bar(int step, int total_steps) {
  int resolution = 100;
  int width = 50;
  if (total_steps / resolution == 0) return;
  double ratio = double(step) / total_steps;
  int count = ratio * width;
  std::string fill(count, '=');
  std::cout << std::setiosflags(std::ios::fixed)
            << std::setprecision(2)
            << ratio * 100.0 << " %"
            << " ["
            << std::setw(width)
            << std::left
            << fill
            << "]"
            << '\r';
}

void Sudoku::process(std::istream& input, std::ostream& output) {
  std::vector<std::string> lines;
  std::copy(std::istream_iterator<std::string>(input),
            std::istream_iterator<std::string>(),
            std::back_inserter(lines));
  int count = 0;
  int total = lines.size();
  for (auto& line: lines) {
    Sudoku sudoku(line);
    sudoku.solve();
    output << sudoku;
    count++;
    progress_bar(count, total);
  }
  std::cout << std::endl;
}
