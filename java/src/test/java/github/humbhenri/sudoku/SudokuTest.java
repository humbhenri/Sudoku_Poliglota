package github.humbhenri.sudoku;

import static github.humbhenri.sudoku.Sudoku.solve;
import static org.junit.Assert.assertArrayEquals;

import org.junit.Test;

public class SudokuTest {

	@Test
	public void testSolve() {
		int sudoku[][] = {{2, 0, 0, 0, 0, 0, 0, 6, 0},
                          {0, 0, 0, 0, 7, 5, 0, 3, 0},
                          {0, 4, 8, 0, 9, 0, 1, 0, 0},
                          {0, 0, 0, 3, 0, 0, 0, 0, 0},
                          {3, 0, 0, 0, 1, 0, 0, 0, 9},
                          {0, 0, 0, 0, 0, 8, 0, 0, 0},
                          {0, 0, 1, 0, 2, 0, 5, 7, 0},
                          {0, 8, 0, 7, 3, 0, 0, 0, 0},
                          {0, 9, 0, 0, 0, 0, 0, 0, 4}};
		int result[][] = solve(sudoku);
		int expected[][] = {{2, 7, 3, 4, 8, 1, 9, 6, 5},
	                        {9, 1, 6, 2, 7, 5, 4, 3, 8},
	                        {5, 4, 8, 6, 9, 3, 1, 2, 7},
	                        {8, 5, 9, 3, 4, 7, 6, 1, 2},
	                        {3, 6, 7, 5, 1, 2, 8, 4, 9},
	                        {1, 2, 4, 9, 6, 8, 7, 5, 3},
	                        {4, 3, 1, 8, 2, 9, 5, 7, 6},
	                        {6, 8, 5, 7, 3, 4, 2, 9, 1},
	                        {7, 9, 2, 1, 5, 6, 3, 8, 4}};
		for (int i=0; i<result.length; i++) {
			assertArrayEquals(expected[i], result[i]);
		}
	}
}