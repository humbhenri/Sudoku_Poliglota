#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <iterator>
#include <time.h>
#include <sys/time.h>

const int BOARD_SIZE = 9;

bool nextEmpty(int sudoku[][BOARD_SIZE], int spot[2]);

bool canPut(int sudoku[][BOARD_SIZE], int spot[2], int val);

void solve(int sudoku [][BOARD_SIZE]);

void fromString(const std::string &data, int board[][BOARD_SIZE]);

std::string toString(int board[][BOARD_SIZE]);


int main(int argc, char const *argv[])
{
	std::ifstream infile(argv[1]);
	if (infile)	 {

		// read entire file into memory
		std::string fileData((std::istreambuf_iterator<char> (infile)) ,
			std::istreambuf_iterator<char>()) ;
		infile.close();
        std::stringstream ssinput (fileData);


		// solve all sudokus
		struct timeval before;
		gettimeofday (&before, NULL);

		std::stringstream ssoutput;
		std::string line;
		while (std::getline (ssinput, line)) {
			int board[BOARD_SIZE][BOARD_SIZE];
			fromString (line, board);
			solve (board);
			ssoutput << toString (board);
		}

		struct timeval after;
		gettimeofday (&after, NULL);
		long duration = ((after.tv_sec * 1000000 + after.tv_usec) -
			(before.tv_sec * 1000000 + before.tv_usec)) / 1000;

		// write solutions to output
		std::ofstream outfile;
		std::string path (argv[1]);
		std::string name;
		if (unsigned found = path.find_last_of ("/\\")) {
			name = "solved_" + path.substr(found+1);
		} else {
			name = std::string ("solved_") + argv[1];
		}
		outfile.open (name.c_str());
		outfile << ssoutput.str();
		outfile.close();

		// time result
		std::cout << "-- Elapsed time: " << duration << " ms." << std::endl;

		return 0;
	}

	return 0;
}


bool nextEmpty(int sudoku[][BOARD_SIZE], int spot[2]) {
	for (int i=0; i<BOARD_SIZE; i++) {
		for (int j=0; j<BOARD_SIZE; j++) {
			if (sudoku[i][j] == 0) {
				spot[0] = i;
				spot[1] = j;
				return true;
			}
		}
	}
	return false;
}


bool canPut(int sudoku[][BOARD_SIZE], int spot[2], int val) {
	int x = spot[0];
	int y = spot[1];
	for (int i=0; i<BOARD_SIZE; i++) {
            // test row
		if (sudoku[i][y] == val) {
			return false;
		}
            // test column
		if (sudoku[x][i] == val) {
			return false;
		}
	}
     // test square
	int a = x-(x%3);
	int b = y-(y%3);
	for (int i=a; i<a+3; i++) {
		for (int j=b; j<b+3; j++) {
			if (sudoku[i][j] == val) {
				return false;
			}
		}
	}

	return true;
}


void solve(int sudoku [][BOARD_SIZE]) {
	int spot[] = {0, 0};
	if (!nextEmpty(sudoku, spot)) {
		return;
	}

	for (int i=1; i<10; i++) {
		if (canPut(sudoku, spot, i)) {
			sudoku[spot[0]][spot[1]] = i;
			solve(sudoku);
			int _[] = {0, 0};
			if (!nextEmpty(sudoku, _)) {
				return;
			}
		}
	}

        sudoku[spot[0]][spot[1]] = 0; // solution not found, backtrack
    }


void fromString(const std::string &data, int board[][BOARD_SIZE]) {
	int i = 0, j = 0;
	for (std::string::const_iterator it=data.begin();
		it!=data.end() && i < BOARD_SIZE && j < BOARD_SIZE;
		++it) {
		if (isdigit(*it)) {
			board[i][j] = *it - 48;
		}
       if (j == BOARD_SIZE - 1) {
            i += 1 % BOARD_SIZE;
            j = 0;
        } else {
            j += 1 % BOARD_SIZE;
        }
	}
}


std::string toString(int board[][BOARD_SIZE]) {
	std::stringstream ss;
	for (int i=0; i<BOARD_SIZE; i++) {
		for (int j=0; j<BOARD_SIZE; j++) {
			ss << board[i][j] << " ";
		}
		ss << "\n";
	}
	ss << "\n";
	return ss.str();
}

