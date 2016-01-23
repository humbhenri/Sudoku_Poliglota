#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <iterator>
#include <time.h>
#include <sys/time.h>
#include "Sudoku.h"


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
			auto sudoku = Sudoku(line);
      sudoku.solve();
			ssoutput << sudoku;
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
	}

	return 0;
}


