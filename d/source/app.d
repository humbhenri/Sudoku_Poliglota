import std.stdio;
import std.file;
import std.array;
import std.range;
import std.string;
import std.algorithm;
import std.functional;
import std.conv;
import std.ascii;
import core.stdc.stdlib;
import std.path;

alias sudoku = int[][];

private const BOARD_SZ = 9;

void main(string[] args)
{
    if (args.length != 2)
    {
        writeln("File with input is necessary.");
        exit(1);
    }
    const inputname = args[1];
    const outputname = "solved_" ~ baseName(inputname);
    std.file.write(outputname, "");
    inputname.readText
        .strip
        .lineSplitter
        .filter!(not!empty)
        .map!toSudoku
        .each!((sudoku aSudoku) {
            aSudoku.solve;
            append(outputname, aSudoku.toStr ~ "\n\n");
        });
}

private sudoku toSudoku(string s)
{
    return s.map!(x => to!int(x) - '0').chunks(BOARD_SZ).map!array.array;
}

private string toStr(sudoku aSudoku)
{
    return aSudoku.map!(row => row.map!(to!string).joiner(" ")).joiner("\n").to!string;
}

unittest
{
    sudoku aSudoku = "200000060000075030048090100000300000300010009000008000001020570080730000090000004"
        .toSudoku;
    assert(aSudoku.toStr.equal("2 0 0 0 0 0 0 6 0
0 0 0 0 7 5 0 3 0
0 4 8 0 9 0 1 0 0
0 0 0 3 0 0 0 0 0
3 0 0 0 1 0 0 0 9
0 0 0 0 0 8 0 0 0
0 0 1 0 2 0 5 7 0
0 8 0 7 3 0 0 0 0
0 9 0 0 0 0 0 0 4"));
}

private auto nextEmpty(sudoku aSudoku, ref int x, ref int y)
{
    foreach (i, row; aSudoku)
    {
        foreach (j, n; row)
        {
            if (n == 0)
            {
                x = cast(int) i;
                y = cast(int) j;
                return true;
            }
        }
    }
    return false;
}

unittest
{
    sudoku aSudoku = "200000060000075030048090100000300000300010009000008000001020570080730000090000004"
        .toSudoku;
    auto x = -1;
    auto y = -1;
    assert(aSudoku.nextEmpty(x, y));
    assert(x == 0);
    assert(y == 1);
}

private auto canPut(sudoku aSudoku, int x, int y, int value)
{
    for (auto i = 0; i < BOARD_SZ; i++)
    {
        if (aSudoku[i][y] == value)
        {
            return false; // value already exists in line i
        }
        if (aSudoku[x][i] == value)
        {
            return false; // value already exists in column i
        }
    }
    const a = x - (x % 3);
    const b = y - (y % 3);
    for (int i = a; i < a + 3; i++)
    {
        for (int j = b; j < b + 3; j++)
        {
            if (aSudoku[i][j] == value)
            {
                return false; // value already exists in square
            }
        }
    }

    return true;
}

unittest
{
    sudoku aSudoku = "200000060000075030048090100000300000300010009000008000001020570080730000090000004"
        .toSudoku;
    assert(canPut(aSudoku, 0, 1, 5));
    assert(!canPut(aSudoku, 0, 1, 2));
}

private auto solve(sudoku aSudoku)
{
    int x, y;
    if (!aSudoku.nextEmpty(x, y))
    {
        return;
    }
    for (int i = 1; i < 10; i++)
    {
        if (aSudoku.canPut(x, y, i))
        {
            aSudoku[x][y] = i;
            aSudoku.solve;
            int a, b;
            if (!aSudoku.nextEmpty(a, b))
            {
                return;
            }
        }
    }
    // solution not found, backtrack
    aSudoku[x][y] = 0;
}

unittest
{
    sudoku aSudoku = "200000060000075030048090100000300000300010009000008000001020570080730000090000004"
        .toSudoku;
    aSudoku.solve;
    assert(aSudoku.toStr.equal("2 7 3 4 8 1 9 6 5
9 1 6 2 7 5 4 3 8
5 4 8 6 9 3 1 2 7
8 5 9 3 4 7 6 1 2
3 6 7 5 1 2 8 4 9
1 2 4 9 6 8 7 5 3
4 3 1 8 2 9 5 7 6
6 8 5 7 3 4 2 9 1
7 9 2 1 5 6 3 8 4"));
}
