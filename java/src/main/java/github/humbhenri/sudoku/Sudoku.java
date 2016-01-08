package github.humbhenri.sudoku;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

public class Sudoku {

	static class Spot {
		int row;

		int col;

		Spot(int row, int col) {
			this.row = row;
			this.col = col;
		}
	}

	/**
	 * The array is modified in place
	 * 
	 * @param sudoku
	 */
	public static int[][] solve(int[][] sudoku) {
		Spot spot = nextEmptySpot(sudoku);
		if (spot == null) {
			return sudoku;
		}

		for (int tryValue = 1; tryValue < 10; tryValue++) {
			if (canPut(sudoku, spot, tryValue)) {
				put(sudoku, spot, tryValue);
				int[][] newSudoku = solve(sudoku);
				if (nextEmptySpot(newSudoku) == null) {
					return newSudoku;
				}
			}
		}

		put(sudoku, spot, 0); // solution not found, backtrack
		return sudoku;
	}

	private static void put(int[][] sudoku, Spot spot, int value) {
		sudoku[spot.row][spot.col] = value;
	}

	private static Spot nextEmptySpot(int[][] sudoku) {
		for (int i = 0; i < sudoku.length; i++) {
			for (int j = 0; j < sudoku[i].length; j++) {
				if (sudoku[i][j] == 0) {
					return new Spot(i, j);
				}
			}
		}
		return null;
	}

	private static boolean canPut(int[][] sudoku, Spot spot, int val) {
		int x = spot.row;
		int y = spot.col;
		for (int i = 0; i < sudoku.length; i++) {
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
		int a = x - (x % 3);
		int b = y - (y % 3);
		for (int i = a; i < a + 3; i++) {
			for (int j = b; j < b + 3; j++) {
				if (sudoku[i][j] == val) {
					return false;
				}
			}
		}

		return true;
	}

	public static final int BOARD_SIZE = 9;

	public static int[][] fromString(String data) {
		int[][] board = new int[BOARD_SIZE][BOARD_SIZE];
		for (int row = 0; row < BOARD_SIZE; row++) {
			for (int col = 0; col < BOARD_SIZE; col++) {
				int index = row * BOARD_SIZE + col;
				board[row][col] = Character.getNumericValue(data.charAt(index));
			}
		}
		return board;
	}

	public static String toString(int[][] board) {
		StringBuilder out = new StringBuilder();
		for (int i = 0; i < board.length; i++) {
			for (int j = 0; j < board[i].length; j++) {
				out.append(board[i][j]).append(" ");
			}
			out.append("\n");
		}
		out.append("\n");
		return out.toString();
	}

	public static void main(String[] args) throws IOException {
		checkRequiredInputFile(args);
		long before = System.currentTimeMillis();
		Path input = Paths.get("", args[0]);
		List<String> lines = Files.readAllLines(input, Charset.defaultCharset());
		StringBuilder output = solveAllSudokus(lines);
		long duration = System.currentTimeMillis() - before;
		Path outputFile = Paths.get(input.getParent().toString(), "solved_" + input.getFileName());
		Files.write(outputFile, output.toString().getBytes());
		System.out.println("-- Elapsed time: " + duration + " ms.");
	}

	private static void checkRequiredInputFile(String[] args) {
		if (args.length == 0) {
			System.out.println("input required, please specify a file name with sudokus to solve.");
			System.exit(1);
		}
	}

	private static StringBuilder solveAllSudokus(List<String> lines) {
		StringBuilder output = new StringBuilder();
		ProgressBar bar = new ProgressBar(0, lines.size(), 100, 100);
		for (String line: lines) {
			int[][] sudoku = fromString(line);
			output.append(toString(solve(sudoku)));
			bar.advance();
		}
		return output;
	}
}

class ProgressBar {
	private int totalSteps;

	private int step;

	private int resolution;

	private int width;

	public ProgressBar(int step, int totalSteps, int resolution, int width) {
		this.step = step;
		this.totalSteps = totalSteps;
		this.resolution = resolution;
		this.width = width;
	}

	public void advance() {
		step++;
		if (totalSteps / resolution == 0)
			return;
		if (step % (totalSteps / resolution) != 0)
			return;
		float ratio = step / (float) totalSteps;
		int count = (int) (ratio * width);
		System.out.printf("%3d%% [", (int) (ratio * 100));
		for (int i = 0; i < count; i++)
			System.out.print("=");
		for (int i = count; i < width; i++)
			System.out.print(" ");
		System.out.print("]\r");
		System.out.flush();
	}
}
