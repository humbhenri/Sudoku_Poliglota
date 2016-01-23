#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MODULE Tests
#include <boost/test/unit_test.hpp>
#include "Sudoku.h"

BOOST_AUTO_TEST_CASE(solvingASudoku)
{
  std::string example("008009320000080040900500007000040090000708000060020000600001008050030000072900100");
  Sudoku sudoku(example);
  sudoku.solve();
  std::stringstream ss;
  ss << sudoku;
  const char *solution = R"DEL(7 1 8 4 6 9 3 2 5 
5 2 6 3 8 7 9 4 1 
9 3 4 5 1 2 8 6 7 
1 8 7 6 4 3 5 9 2 
2 4 5 7 9 8 6 1 3 
3 6 9 1 2 5 7 8 4 
6 9 3 2 7 1 4 5 8 
4 5 1 8 3 6 2 7 9 
8 7 2 9 5 4 1 3 6 

)DEL";
  BOOST_CHECK_MESSAGE(ss.str() == solution, "this is not the solution: " + ss.str());
}
