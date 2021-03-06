# Sudoku solver using backtrack

import io
import sys
import time
import os

BOARD_SIZE = 9


def show_progress_bar(step, total_steps, resolution, width):
    if total_steps / resolution == 0:
        return
    if step % (total_steps / resolution) != 0:
        return
    ratio = step / float(total_steps)
    count = int(ratio * width)
    print('%3d%% ['.format(int(ratio * 100)))
    for x in range(0, count):
        sys.stdout.write('=')
    for x in range(count, width):
        sys.stdout.write(' ')
    sys.stdout.write(']\r')
    sys.stdout.flush()


def next_empty(sudoku):
    empty_slots = ((i, j) 
        for i in range(0, BOARD_SIZE) 
        for j in range(0, BOARD_SIZE) 
        if sudoku[i][j] == 0) 
    return next(empty_slots, None)


def can_put(sudoku, x, y, val):
    if any(val in (sudoku[i][y], sudoku[x][i]) for i in range(0, BOARD_SIZE)):
        return False
    sq_x = x - (x % 3)
    sq_y = y - (y % 3)
    if any(sudoku[i][j] == val for i in range(sq_x, sq_x + 3) for j in range(sq_y, sq_y + 3)):
        return False
    return True
    

def solve(sudoku):
    spot = next_empty(sudoku)
    if spot is None:
        return sudoku
    x, y = spot
    for i in range(1, 10):
        if can_put(sudoku, x, y, i):
            sudoku[x][y] = i
            new_sudoku = solve(sudoku)
            if next_empty(new_sudoku) is None:
                return new_sudoku  #found solution

    sudoku[x][y] = 0  #solution not found, backtrack
    return sudoku


def to_str(sudoku):
    return '\n'.join(' '.join(map(str, row)) for row in sudoku)


def from_str(data):
    rows = (data[i:i + BOARD_SIZE] for i in range(0, len(data), BOARD_SIZE))
    return [list(map(int, row)) for row in rows]


def process(input, output):
    data = input.read()
    before = time.time()
    sudokus = data.splitlines()
    total_sudokus = len(sudokus)
    solved_sudokus = 0
    for line in sudokus:
        sudoku = from_str(line)
        sudoku = solve(sudoku)
        output.write(to_str(sudoku) + '\n')
        solved_sudokus += 1
        show_progress_bar(step=solved_sudokus, total_steps=total_sudokus, resolution=100, width=50)
    after = time.time()
    print('--Elapsed {:.2f} ms'.format((after - before) * 1000))


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Please inform the input file')
        sys.exit(1)
    filename = sys.argv[1]
    with io.open(filename, 'r') as input, \
            io.open('solved_' + os.path.basename(filename), 'w') as output: 
        process(input, output)
