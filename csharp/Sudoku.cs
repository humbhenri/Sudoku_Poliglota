using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Diagnostics;

namespace Sudoku
{
    class Sudoku
    {
        public const int BOARD_SIZE = 9;

        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                System.Console.WriteLine("Insert file input");
                Environment.Exit(0);
            }
            var input = args[0];

            // read input into memory
            var data = File.ReadAllText(input);

            var stopwatch = new Stopwatch();

            var result = new StringBuilder();

            // solve all sudokus
            stopwatch.Start();
            foreach (string line in data.Trim().Split('\n'))
            {
                var sudoku = FromString(line);
                sudoku = Solve(sudoku);
                result.Append(ToString(sudoku));
            }
            stopwatch.Stop();
            // write solutions to file
            var output = "solved_" + Path.GetFileName(input);
            File.WriteAllText(output, result.ToString());

            // present time result
            System.Console.WriteLine(" -- Elapsed time: {0} ms.", stopwatch.ElapsedMilliseconds);
        }

        static int[,] FromString(string data)
        {
            var sudoku = new int[BOARD_SIZE, BOARD_SIZE];
            int i = 0, j = 0;
            foreach (char c in data)
            {
                if (Char.IsDigit(c))
                {
                    sudoku[i, j] = c - 48;
                    if (j == BOARD_SIZE - 1)
                    {
                        i += 1 % BOARD_SIZE;
                        j = 0;
                    }
                    else
                    {
                        j += 1 % BOARD_SIZE;
                    }
                }
            }
            return sudoku;
        }

        static string ToString(int[,] sudoku)
        {
            var sb = new StringBuilder();
            for (int i = 0; i < BOARD_SIZE; i++)
            {
                for (int j = 0; j < BOARD_SIZE; j++)
                {
                    sb.Append(sudoku[i, j] + " ");
                }
                sb.Append('\n');
            }
            sb.Append('\n');
            return sb.ToString();
        }

        static int[] NextEmpty(int[,] sudoku)
        {
            for (int i = 0; i < BOARD_SIZE; i++)
            {
                for (int j = 0; j < BOARD_SIZE; j++)
                {
                    if (sudoku[i, j] == 0)
                    {
                        return new int[] { i, j };
                    }
                }
            }
            return null;
        }

        static bool CanPut(int[,] sudoku, int x, int y, int val)
        {
            for (int i = 0; i < BOARD_SIZE; i++)
            {
                if (sudoku[i, y] == val) // test rows
                {
                    return false;
                }
                if (sudoku[x, i] == val) // test columns
                {
                    return false;
                }
            }
            // test square
            int a = x - (x % 3);
            int b = y - (y % 3);
            for (int i = a; i < a + 3; i++)
            {
                for (int j = b; j < b + 3; j++)
                {
                    if (sudoku[i, j] == val)
                    {
                        return false;
                    }
                }
            }
            return true;
        }

        static int[,] Solve(int[,] sudoku)
        {
            var spot = NextEmpty(sudoku);
            if (spot == null)
            {
                return sudoku;
            }
            for (int i = 1; i < 10; i++)
            {
                if (CanPut(sudoku, spot[0], spot[1], i))
                {
                    sudoku[spot[0], spot[1]] = i;
                    var newSudoku = Solve(sudoku);
                    if (NextEmpty(newSudoku) == null)
                    {
                        return newSudoku; // solution found
                    }
                }
            }

            sudoku[spot[0], spot[1]] = 0; // solution not found, backtrack
            return sudoku;
        }
    }
}
