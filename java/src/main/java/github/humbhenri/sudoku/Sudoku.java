package github.humbhenri.sudoku;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;

public class Sudoku {

    /**
     * The array is modified in place
     * @param sudoku
     */
    public static int[][] solve(int[][] sudoku) {
        int spot[] = {0, 0};
        if (!nextEmpty(sudoku, spot)) {
            return sudoku;
        }

        for (int i=1; i<10; i++) {
            if (canPut(sudoku, spot, i)) {
                sudoku[spot[0]][spot[1]] = i;
                int [][]newSudoku = solve(sudoku);
                if (!nextEmpty(newSudoku, new int[]{0, 0})) {
                    return newSudoku;
                }
            }
        }

        sudoku[spot[0]][spot[1]] = 0; // solution not found, backtrack
        return sudoku;
    }

    private static boolean nextEmpty(int[][] sudoku, int[] spot) {
        for (int i=0; i<sudoku.length; i++) {
            for (int j=0; j<sudoku[i].length; j++) {
                if (sudoku[i][j] == 0) {
                    spot[0] = i;
                    spot[1] = j;
                    return true;
                }
            }
        }
        return false;
    }

    private static boolean canPut(int[][] sudoku, int[] spot, int val) {
        int x = spot[0];
        int y = spot[1];
        for (int i=0; i<sudoku.length; i++) {
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

    public static void main(String[] args) {
    	if (args.length == 0) {
    		System.out.println("input required, please specify a file name with sudokus to solve.");
    		System.exit(1);
    	}
    	
        File file = new File(args[0]);

        // read entire file into memory
        String input = null;
        try {
            input = new Scanner(file, "UTF-8").useDelimiter("\\A").next();
        } catch (FileNotFoundException e) {
            System.out.println("Could not find " + file.getName());
            System.exit(1);
        }

        // solve all sudokus
        long before = System.currentTimeMillis();

        StringBuilder output = new StringBuilder();
        String []lines = input.split("\\r?\\n");
        ProgressBar bar = new ProgressBar(0, lines.length, 100, 100);
        for (String line : lines) {
            int [][]sudoku = Board.fromString(line);
            output.append(Board.toString(solve(sudoku)));
            bar.advance();
        }

        long duration = System.currentTimeMillis() - before;

        // write solution to file output
        BufferedWriter writer = null;
        try {
            writer = new BufferedWriter(new FileWriter("solved_" + file.getName()));
            writer.write(output.toString());
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }

        // time result
        System.out.println("-- Elapsed time: " + duration + " ms.");
    }
}

class Board {

    public static final int BOARD_SIZE = 9;

    public static int[][] fromString(String data) {
        int[][] board = new int[BOARD_SIZE][BOARD_SIZE];
        int i = 0, j = 0, ch = 0;
        while (i < BOARD_SIZE && j < BOARD_SIZE) {
            while (!Character.isDigit(data.charAt(ch))) {
                ch++;
            }
            board[i][j] = data.charAt(ch++) - 48;
            if (j == BOARD_SIZE - 1) {
                i += 1 % BOARD_SIZE;
                j = 0;
            } else {
                j += 1 % BOARD_SIZE;
            }
        }
        return board;
    }

    public static String toString(int[][] board) {
        StringBuilder out = new StringBuilder();
        for (int i=0; i<board.length; i++) {
            for (int j=0; j<board[i].length; j++) {
                out.append(board[i][j]).append(" ");
            }
            out.append("\n");
        }
        out.append("\n");
        return out.toString();
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
