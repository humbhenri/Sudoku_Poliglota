// Sudoku sover in Go
package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"time"
)

const BOARD_SIZE = 9 // rows and column size

// Progress bar
func LoadBar(step int, totalSteps int, resolution int, width int) {
	if totalSteps/resolution == 0 {
		return
	}
	if step%(totalSteps/resolution) != 0 {
		return
	}
	var ratio float64 = float64(step) / float64(totalSteps)
	var count int = int(ratio * float64(width))
	os.Stdout.Write([]byte(fmt.Sprintf("%3d%% [", int(ratio*100))))
	for i := 0; i < count; i++ {
		os.Stdout.Write([]byte("="))
	}
	for i := count; i < width; i++ {
		os.Stdout.Write([]byte(" "))
	}
	os.Stdout.Write([]byte(fmt.Sprintf("]\r")))
	os.Stdout.Sync()
}

// Build a slice of slices to represent the board from a string
func FromStr(boardRepr string) [][]int {
	board := make([][]int, BOARD_SIZE)
	for i := range board {
		board[i] = make([]int, BOARD_SIZE)
	}

	x, y := 0, 0
	for i := range boardRepr {
		if boardRepr[i] >= '0' && boardRepr[i] <= '9' {
			board[x][y] = int(boardRepr[i]) - 48
			if y == BOARD_SIZE-1 {
				x += 1 % BOARD_SIZE
				y = 0
			} else {
				y += 1 % BOARD_SIZE
			}
		}
	}

	return board
}

// Board to string
func ToStr(board [][]int) string {
	var b bytes.Buffer
	for i := range board {
		for j := range board[i] {
			b.WriteString(fmt.Sprintf("%d ", board[i][j]))
		}
		b.WriteString("\n")
	}
	return b.String()
}

// Return the next spot where is possible to put a number
func nextEmpty(board [][]int) []int {
	for i := range board {
		for j := range board[i] {
			if board[i][j] == 0 {
				return []int{i, j}
			}
		}
	}
	return nil
}

// Return true if the number n can be put in the board at specific spot
func canPut(board [][]int, spot []int, n int) bool {
	x, y := spot[0], spot[1]
	for i := range board {
		// test line
		if board[i][y] == n {
			return false
		}
		// test column
		if board[x][i] == n {
			return false
		}
	}
	// test square
	a, b := x-(x%3), y-(y%3)
	for i := a; i < a+3; i++ {
		for j := b; j < b+3; j++ {
			if board[i][j] == n {
				return false
			}
		}
	}

	return true
}

// Solve using backtracking
func solve(board [][]int) [][]int {
	spot := nextEmpty(board)
	if spot == nil {
		return board
	}
	x, y := spot[0], spot[1]
	for i := 1; i < 10; i++ {
		if canPut(board, spot, i) {
			board[x][y] = i
			newBoard := solve(board)
			if nextEmpty(newBoard) == nil {
				// solution found
				return newBoard
			}
		}
	}
	// solution not found, backtrack
	board[x][y] = 0
	return board
}

func processBatch(file string) {
	data, err := ioutil.ReadFile(file)
	if err != nil {
		panic(err)
	}
	var solvedOutput bytes.Buffer
	lines := strings.Split(string(data), "\n")
	total := len(lines)
	count := 0
	before := time.Now()
	for _, line := range lines {
		sudoku := FromStr(line)
		solvedOutput.WriteString(ToStr(solve(sudoku)))
		solvedOutput.WriteString("\n")
		LoadBar(count, total, 20, 50)
		count++
	}
	diff := time.Now().Sub(before)
	fmt.Printf("-- Solved %d sudokus. Elapsed time: %f seconds\n", count, diff.Seconds())
	err = ioutil.WriteFile("solved_"+file, solvedOutput.Bytes(), 0644)
	if err != nil {
		panic(err)
	}
}

func main() {
	file := os.Args[1]
	processBatch(file)
}
