package github.humbhenri.sudoku;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

public class SudokuTest {
	
	private static final String SUDOKU_EXAMPLE = "200000060000075030048090100000300000300010009000008000001020570080730000090000004";
	private static final String EXPECTED = "2 7 3 4 8 1 9 6 5 \n"
										+ "9 1 6 2 7 5 4 3 8 \n"
										+ "5 4 8 6 9 3 1 2 7 \n"
										+ "8 5 9 3 4 7 6 1 2 \n"
										+ "3 6 7 5 1 2 8 4 9 \n"
										+ "1 2 4 9 6 8 7 5 3 \n"
										+ "4 3 1 8 2 9 5 7 6 \n"
										+ "6 8 5 7 3 4 2 9 1 \n"
										+ "7 9 2 1 5 6 3 8 4 \n\n" ;

	@Rule
	public TemporaryFolder tempFolder = new TemporaryFolder();
	
	@Test
	public void testSolve() {
		Sudoku sudoku = Sudoku.fromString(SUDOKU_EXAMPLE);
		sudoku.solve();
		assertEquals(EXPECTED, sudoku.toString());
	}
	
	@Test
	public void testReadAndWriteFiles() throws IOException {
		File input = tempFolder.newFile();
		Files.write(input.toPath(), SUDOKU_EXAMPLE.getBytes());
		Sudoku.main(new String[] { input.getAbsolutePath() });
		Path outputFile = Paths.get(tempFolder.getRoot().getAbsolutePath(), "solved_" + input.getName());
		byte[] output = Files.readAllBytes(outputFile);
		assertTrue(Files.exists(outputFile));
		assertEquals(EXPECTED, new String(output));
	}
}
