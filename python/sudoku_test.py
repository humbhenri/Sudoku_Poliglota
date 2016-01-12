import unittest
from sudoku import *
from copy import deepcopy

SUDOKU_SAMPLE = [
            [2, 0, 0, 0, 0, 0, 0, 6, 0],
            [0, 0, 0, 0, 7, 5, 0, 3, 0],
            [0, 4, 8, 0, 9, 0, 1, 0, 0],
            [0, 0, 0, 3, 0, 0, 0, 0, 0],
            [3, 0, 0, 0, 1, 0, 0, 0, 9],
            [0, 0, 0, 0, 0, 8, 0, 0, 0],
            [0, 0, 1, 0, 2, 0, 5, 7, 0],
            [0, 8, 0, 7, 3, 0, 0, 0, 0],
            [0, 9, 0, 0, 0, 0, 0, 0, 4]]

SUDOKU_SAMPLE_LINE = "200000060000075030048090100000300000300010009000008000001020570080730000090000004"

SUDOKU_SAMPLE_FORMATED = """2 0 0 0 0 0 0 6 0
0 0 0 0 7 5 0 3 0
0 4 8 0 9 0 1 0 0
0 0 0 3 0 0 0 0 0
3 0 0 0 1 0 0 0 9
0 0 0 0 0 8 0 0 0
0 0 1 0 2 0 5 7 0
0 8 0 7 3 0 0 0 0
0 9 0 0 0 0 0 0 4
"""

SUDOKU_SOLUTION = [[2, 7, 3, 4, 8, 1, 9, 6, 5],
                   [9, 1, 6, 2, 7, 5, 4, 3, 8],
                   [5, 4, 8, 6, 9, 3, 1, 2, 7],
                   [8, 5, 9, 3, 4, 7, 6, 1, 2],
                   [3, 6, 7, 5, 1, 2, 8, 4, 9],
                   [1, 2, 4, 9, 6, 8, 7, 5, 3],
                   [4, 3, 1, 8, 2, 9, 5, 7, 6],
                   [6, 8, 5, 7, 3, 4, 2, 9, 1],
                   [7, 9, 2, 1, 5, 6, 3, 8, 4]]

SUDOKU_SOLUTION_FORMATED = u"""2 7 3 4 8 1 9 6 5
9 1 6 2 7 5 4 3 8
5 4 8 6 9 3 1 2 7
8 5 9 3 4 7 6 1 2
3 6 7 5 1 2 8 4 9
1 2 4 9 6 8 7 5 3
4 3 1 8 2 9 5 7 6
6 8 5 7 3 4 2 9 1
7 9 2 1 5 6 3 8 4"""

class TestSudoku(unittest.TestCase):
    def test_from_str(self):
        self.assertEqual(SUDOKU_SAMPLE, from_str(SUDOKU_SAMPLE_LINE))

    def test_to_str(self):
        self.assertEqual(SUDOKU_SAMPLE_FORMATED.strip(), to_str(SUDOKU_SAMPLE).strip())

    def test_solve(self):
        self.assertEqual(SUDOKU_SOLUTION, solve(deepcopy(SUDOKU_SAMPLE)))

    def test_process(self):
        input = io.StringIO()
        input.write(SUDOKU_SAMPLE_LINE)
        input.seek(0)
        output = io.StringIO()
        process(input, output)
        results = output.getvalue()
        input.close()
        output.close()
        self.assertEqual(SUDOKU_SOLUTION_FORMATED.strip(), results.strip())

if __name__ == '__main__':
    unittest.main()
