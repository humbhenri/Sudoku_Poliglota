# Sudoku solver using backtrack

import io
import sys
import time
import os

BOARD_SIZE=9

def load_bar(step, total_steps, resolution, width):
    if total_steps/resolution == 0 :
        return
    if step % (total_steps/resolution) != 0:
        return
    ratio = step/float(total_steps)
    count = int(ratio * width)
    print '%3d%% [' % int(ratio*100) ,
    for x in xrange(0, count):
        sys.stdout.write('=')
    for x in xrange(count, width):
        sys.stdout.write(' ')
    sys.stdout.write(']\r')
    sys.stdout.flush()

def next_empty(sudoku):
    for i in xrange(0, len(sudoku)):
        for j in xrange(0, len(sudoku[i])):
            if sudoku[i][j] == 0:
                return i,j
    return None


def can_put(sudoku, x, y, val):
    for i in xrange(0, len(sudoku)):
        if sudoku[i][y] == val:
            return False
        if sudoku[x][i] == val:
            return False
    sq_x = x-(x%3)
    sq_y = y-(y%3)
    for i in xrange(sq_x, sq_x+3):
        for j in xrange(sq_y, sq_y+3):
            if sudoku[i][j] == val:
                return False
    return True


def solve(sudoku):
    spot = next_empty(sudoku)
    if spot is None:
        return sudoku
    x, y = spot
    for i in xrange(1, 10):
        if can_put(sudoku, x, y, i):
            sudoku[x][y] = i
            new_sudoku = solve(sudoku)
            if next_empty(new_sudoku) is None:
                return new_sudoku #found solution

    sudoku[x][y] = 0 #solution not found, backtrack
    return sudoku


def to_str(sudoku):
    return '\n'.join([' '.join(map(str, row)) for row in sudoku])


def from_str(data):
    rows = [data[i:i+BOARD_SIZE] for i in xrange(0, len(data), BOARD_SIZE)]
    return [map(int,list(row)) for row in rows]


def process(input, output):
    data = input.read()
    print 'data is ' + data

    # solve all sudokus
    before = time.time()
    sudokus = data.splitlines()
    total_sudokus = len(sudokus)
    solved_sudokus = 0
    result = []
    for line in sudokus:
        sudoku = from_str(line)
        sudoku = solve(sudoku)
        result.append(to_str(sudoku))
        solved_sudokus += 1
        load_bar(solved_sudokus, total_sudokus, 100, 50)
    after = time.time()

    # write solutions to file
    output.write(unicode('\n\n'.join(result)))

    # present results
    print '--Elapsed %f ms' % ((after-before)*1000)

if __name__ == '__main__':
    try:
        filename = sys.argv[1]
        with io.open(filename, 'r') as input:
            with io.open('solved_' + os.path.basename(filename), 'w') as output:
                process(input, output)
    except IndexError:
        print 'Insert file input'
        sys.exit(1)
