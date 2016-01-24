#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <iterator>
#include <time.h>
#include <sys/time.h>
#include <cerrno>
#include <cstring>
#include <cstdlib>
#include <boost/filesystem.hpp>
#include <chrono>
#include <ctime>
#include "Sudoku.h"

using namespace boost::filesystem;

int main(int argc, char const *argv[])
{
  if (argc > 1) {
    const std::string filename(argv[1]);
    std::ifstream input(filename);
    path p(filename);
    std::ofstream output("solved_" + p.filename().string());
    if (!input || !output) {
      std::cerr << std::strerror(errno) << std::endl;
      return EXIT_FAILURE;
    }
    std::chrono::time_point<std::chrono::system_clock> start, end;
    start = std::chrono::system_clock::now();
    Sudoku::process(input, output);
    end = std::chrono::system_clock::now();
    int elapsed_seconds = std::chrono::duration_cast<std::chrono::seconds>
      (end-start).count();
    std::cout << "Elapsed seconds: " << elapsed_seconds << std::endl;
    input.close();
    output.close();
  } else {
    std::cerr << "An input file is necessary :(" << std::endl;
  }

  return EXIT_SUCCESS;
}

