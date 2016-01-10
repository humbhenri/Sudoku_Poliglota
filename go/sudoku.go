// Sudoku sover in Go
package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const boardSize = 9 // rows and column size

func loadBar(step int, totalSteps int, resolution int, width int) {
	if totalSteps/resolution == 0 {
		return
	}
	if step%(totalSteps/resolution) != 0 {
		return
	}
	var ratio = float64(step) / float64(totalSteps)
	var count = int(ratio * float64(width))
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
func fromStr(boardRepr string) [][]int {
	board := make([][]int, boardSize)
	for i := range board {
		board[i] = make([]int, boardSize)
	}

	x, y := 0, 0
	for i := range boardRepr {
		if boardRepr[i] >= '0' && boardRepr[i] <= '9' {
			board[x][y] = int(boardRepr[i]) - 48
			if y == boardSize-1 {
				x += 1 % boardSize
				y = 0
			} else {
				y += 1 % boardSize
			}
		}
	}

	return board
}

// Board to string
func toStr(board [][]int) string {
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
	for i := 0; i < boardSize; i++ {
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

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func processBatch(input io.Reader, output io.Writer) {
	data, err := ioutil.ReadAll(input)
	check(err)
	var solvedOutput bytes.Buffer
	lines := strings.Split(string(data), "\n")
	total := len(lines)
	count := 0
	before := time.Now()
	for _, line := range lines {
		sudoku := fromStr(line)
		solvedOutput.WriteString(toStr(solve(sudoku)))
		solvedOutput.WriteString("\n")
		loadBar(count, total, 20, 50)
		count++
	}
	diff := time.Now().Sub(before)
	fmt.Printf("-- Solved %d sudokus. Elapsed time: %f seconds\n", count, diff.Seconds())
	_, err = output.Write(solvedOutput.Bytes())
	check(err)
}

func main() {
	inputFile, err := os.Open(os.Args[1])
	check(err)
	input := bufio.NewReader(inputFile)
	outputFile, err := os.Create("solved_" + filepath.Base(inputFile.Name()))
	check(err)
	output := bufio.NewWriter(outputFile)
	defer inputFile.Close()
	defer outputFile.Close()
	processBatch(input, output)
}
