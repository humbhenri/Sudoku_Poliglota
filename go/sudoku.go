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

type board [][]int

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
func fromStr(boardRepr string) board {
	b := make([][]int, boardSize)
	for i := 0; i < boardSize; i++ {
		b[i] = make([]int, boardSize)
	}

	x, y := 0, 0
	for i := range boardRepr {
		if boardRepr[i] >= '0' && boardRepr[i] <= '9' {
			b[x][y] = int(boardRepr[i]) - 48
			if y == boardSize-1 {
				x += 1 % boardSize
				y = 0
			} else {
				y += 1 % boardSize
			}
		}
	}
	return b
}

func (b *board) get(row, column int) int {
	bslice := [][]int(*b)
	return bslice[row][column]
}

func (b *board) set(row, column, value int) {
	bslice := [][]int(*b)
	bslice[row][column] = value
}

func (b *board) String() string {
	var buf bytes.Buffer
	for i := 0; i < boardSize; i++ {
		for j := 0; j < boardSize; j++ {
			buf.WriteString(fmt.Sprintf("%d ", b.get(i, j)))
		}
		buf.WriteString("\n")
	}
	return buf.String()
}

// Return the next spot where is possible to put a number
func (b *board) nextEmpty() []int {
	for i := 0; i < boardSize; i++ {
		for j := 0; j < boardSize; j++ {
			if b.get(i, j) == 0 {
				return []int{i, j}
			}
		}
	}
	return nil
}

// Return true if the number n can be put in the board at specific spot
func (b *board) canPut(spot []int, n int) bool {
	x, y := spot[0], spot[1]
	for i := 0; i < boardSize; i++ {
		// test line
		if b.get(i, y) == n {
			return false
		}
		// test column
		if b.get(x, i) == n {
			return false
		}
	}
	// test square
	limx, limy := x-(x%3), y-(y%3)
	for i := limx; i < limx+3; i++ {
		for j := limy; j < limy+3; j++ {
			if b.get(i, j) == n {
				return false
			}
		}
	}

	return true
}

// Solve using backtracking
func (b *board) solve() {
	spot := b.nextEmpty()
	if spot == nil {
		return
	}
	x, y := spot[0], spot[1]
	for i := 1; i < 10; i++ {
		if b.canPut(spot, i) {
			b.set(x, y, i)
			b.solve()
			if b.nextEmpty() == nil {
				return
			}
		}
	}
	// solution not found, backtrack
	b.set(x, y, 0)
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
		sudoku.solve()
		solvedOutput.WriteString(sudoku.String())
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
