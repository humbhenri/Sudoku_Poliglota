package github.humbhenri.sudoku;

import static github.humbhenri.sudoku.Sudoku.solve;
import static org.junit.Assert.*;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

public class SudokuTest {
	
	private static final String SUDOKU_EXAMPLE = "200000060000075030048090100000300000300010009000008000001020570080730000090000004";

	@Rule
	public TemporaryFolder tempFolder = new TemporaryFolder();
	
	int sudoku[][] = {{2, 0, 0, 0, 0, 0, 0, 6, 0},
            {0, 0, 0, 0, 7, 5, 0, 3, 0},
            {0, 4, 8, 0, 9, 0, 1, 0, 0},
            {0, 0, 0, 3, 0, 0, 0, 0, 0},
            {3, 0, 0, 0, 1, 0, 0, 0, 9},
            {0, 0, 0, 0, 0, 8, 0, 0, 0},
            {0, 0, 1, 0, 2, 0, 5, 7, 0},
            {0, 8, 0, 7, 3, 0, 0, 0, 0},
            {0, 9, 0, 0, 0, 0, 0, 0, 4}};
	
	@Test
	public void testfromString() {
		int result[][] = Sudoku.fromString(SUDOKU_EXAMPLE);
		for (int row = 0; row < result.length; row++) {
			assertArrayEquals(sudoku[row], result[row]);
		}
	}

	@Test
	public void testSolve() {
		
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
		assertEquals(Sudoku.toString(expected), Sudoku.toString(result));
	}
	
	@Test
	public void testReadAndWriteFiles() throws IOException {
		File input = tempFolder.newFile();
		Files.write(input.toPath(), SUDOKU_EXAMPLE.getBytes());
		
		Sudoku.main(new String[] { input.getAbsolutePath() });
		
		Path outputFile = Paths.get(tempFolder.getRoot().getAbsolutePath(), "solved_" + input.getName());
		byte[] output = Files.readAllBytes(outputFile);
		
		assertTrue(Files.exists(outputFile));
		assertEquals("2 7 3 4 8 1 9 6 5 \n"
				+ "9 1 6 2 7 5 4 3 8 \n"
				+ "5 4 8 6 9 3 1 2 7 \n"
				+ "8 5 9 3 4 7 6 1 2 \n"
				+ "3 6 7 5 1 2 8 4 9 \n"
				+ "1 2 4 9 6 8 7 5 3 \n"
				+ "4 3 1 8 2 9 5 7 6 \n"
				+ "6 8 5 7 3 4 2 9 1 \n"
				+ "7 9 2 1 5 6 3 8 4 \n\n" 
				, new String(output));
	}
}
