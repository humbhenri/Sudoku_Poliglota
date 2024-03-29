# Sudoku solver using backtrack

import io
import sys
import time
import os

BOARD_SIZE = 9


class Sudoku:
    def __init__(self, line):
        self.data = self.from_str(line)
    def from_str(self, line):
        rows = (line[i:i + BOARD_SIZE] for i in range(0, len(line), BOARD_SIZE))
        return [list(map(int, row)) for row in rows]
    def next_empty(self):
        empty_slots = ((i, j)
            for i in range(0, BOARD_SIZE)
            for j in range(0, BOARD_SIZE)
            if self.data[i][j] == 0)
        return next(empty_slots, None)
    def can_put(self, x, y, val):
        if any(val in (self.data[i][y], self.data[x][i]) for i in range(0, BOARD_SIZE)):
            return False
        sq_x = x - (x % 3)
        sq_y = y - (y % 3)
        if any(self.data[i][j] == val for i in range(sq_x, sq_x + 3) for j in range(sq_y, sq_y + 3)):
            return False
        return True
    def solve(self):
        spot = self.next_empty()
        if spot is None:
            return
        x, y = spot
        for i in range(1, 10):
            if self.can_put(x, y, i):
                self.data[x][y] = i
                self.solve()
                if self.next_empty() is None:
                    return #found solution

        self.data[x][y] = 0  #solution not found, backtrack
    def __str__(self):
        return '\n'.join(' '.join(map(str, row)) for row in self.data)


class Process:
    "Iterate over sudokus solving one by one"
    def __init__(self, sudokus):
        self.sudokus = sudokus
        self.index = 0
        self.total_steps = len(self.sudokus)
        self.resolution = 100
        self.width = 50
    def __next__(self):
        try:
            s = Sudoku(self.sudokus[self.index])
            s.solve()
            self.index += 1
            self.show_progress_bar()
            return s
        except IndexError:
            self.index = 0
            raise StopIteration from IndexError
    def __iter__(self):
        return self
    def show_progress_bar(self):
        "Update progress bar"
        if self.total_steps / self.resolution == 0:
            return
        step = self.index
        ratio = step / float(self.total_steps)
        count = int(ratio * self.width)
        percent = ratio * 100
        print(f'{percent:.2f}% [', end='', flush=True)
        for _ in range(0, count):
            print('=', end='', flush=True)
        for _ in range(count, self.width):
            print(' ', end='', flush=True)
        print(']\r', end='', flush=True)


def process(file_input, file_output):
    data = file_input.read()
    before = time.time()
    sudokus = data.splitlines()
    solved_sudokus = 0
    for solved_sudoku in Process(sudokus):
        file_output.write(str(solved_sudoku) + '\n\n')
        solved_sudokus += 1
    after = time.time()
    print()
    elapsed_time = (after - before) * 1000
    print(f'--Elapsed {elapsed_time:.2f} ms')


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Please inform the input file')
        sys.exit(1)
    filename = sys.argv[1]
    with io.open(filename, 'r', encoding='utf-8') as file_input, \
            io.open('solved_' + os.path.basename(filename), 'w', encoding='utf-8') as file_output:
        process(file_input, file_output)
