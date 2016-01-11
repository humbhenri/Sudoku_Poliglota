package github.humbhenri.sudoku;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Scanner;

public class Sudoku {
	
	static class Spot {
		int row;
		int col;
		Spot(int row, int col) {
			this.row = row;
			this.col = col;
		}
	}

	private int[][] board;

	public static Sudoku fromString(String sudokuOneLine) {
		int[][] board = new int[BOARD_SIZE][BOARD_SIZE];
		for (int row = 0; row < BOARD_SIZE; row++) {
			for (int col = 0; col < BOARD_SIZE; col++) {
				int index = row * BOARD_SIZE + col;
				board[row][col] = Character.getNumericValue(sudokuOneLine.charAt(index));
			}
		}
		Sudoku s = new Sudoku();
		s.board = board;
		return s;
	}

	public void solve() {
		Spot spot = nextEmptySpot();
		if (spot == null) {
			return;
		}

		for (int tryValue = 1; tryValue < 10; tryValue++) {
			if (canPut(spot, tryValue)) {
				put(spot, tryValue);
				solve();
				if (nextEmptySpot() == null) {
					return;
				}
			}
		}
		put(spot, 0); // solution not found, backtrack
	}

	private void put(Spot spot, int value) {
		board[spot.row][spot.col] = value;
	}

	private Spot nextEmptySpot() {
		for (int i = 0; i < board.length; i++) {
			for (int j = 0; j < board[i].length; j++) {
				if (board[i][j] == 0) {
					return new Spot(i, j);
				}
			}
		}
		return null;
	}

	private boolean canPut(Spot spot, int val) {
		int x = spot.row;
		int y = spot.col;
		for (int i = 0; i < board.length; i++) {
			if (board[i][y] == val || board[x][i] == val) {
				return false;
			}
		}
		// test square
		int a = x - (x % 3);
		int b = y - (y % 3);
		for (int i = a; i < a + 3; i++) {
			for (int j = b; j < b + 3; j++) {
				if (board[i][j] == val) {
					return false;
				}
			}
		}

        return true;
    }
    

    public static final int BOARD_SIZE = 9;

	@Override
	public String toString() {
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
		if (args.length == 0) {
			System.out.println("input required, please specify a file name with sudokus to solve.");
			System.exit(1);
		}
		long before = System.currentTimeMillis();
		Path input = Paths.get("", args[0]);
		Path outputFile = Paths.get(input.getParent().toString(), "solved_" + input.getFileName());
		List<String> lines = Files.readAllLines(input, Charset.defaultCharset());
		ProgressBar bar = new ProgressBar(0, lines.size(), 100, 100);
		for (String line: lines) {
			Sudoku sudoku = Sudoku.fromString(line);
			sudoku.solve();
			Files.write(outputFile, sudoku.toString().getBytes());
			bar.advance();
		}
		long duration = System.currentTimeMillis() - before;
		System.out.println("-- Elapsed time: " + duration + " ms.");
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
        if (totalSteps/resolution == 0) return;
        if (step % (totalSteps/resolution) != 0) return;
        float ratio = step/(float)totalSteps;
        int count = (int) (ratio * width);
        System.out.printf("%3d%% [", (int) (ratio * 100));
        for (int i=0; i<count; i++) System.out.print("=");
        for (int i=count; i<width; i++) System.out.print(" ");
        System.out.print( "]\r");
        System.out.flush();
    }
}
