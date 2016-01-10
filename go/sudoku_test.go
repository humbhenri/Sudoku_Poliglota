package main

import "testing"
import "strings"
import "bytes"

const (
	sudokuExample = "807000003602080000000200900040005001000798000200100070004003000000040108300000506"
	expected      = `8 9 7 4 5 1 6 2 3 
6 3 2 9 8 7 4 1 5 
4 1 5 2 3 6 9 8 7 
7 4 9 3 2 5 8 6 1 
1 6 3 7 9 8 2 5 4 
2 5 8 1 6 4 3 7 9 
5 8 4 6 1 3 7 9 2 
9 7 6 5 4 2 1 3 8 
3 2 1 8 7 9 5 4 6 
`
)

func TestSolve(t *testing.T) {
	resolved := solve(fromStr(sudokuExample))

	if toStr(resolved) != expected {
		t.Errorf("Resolved was %s but should be %s", toStr(resolved), expected)
	}
}

func TestNextEmpty(t *testing.T) {
	board := fromStr(sudokuExample)
	spot := nextEmpty(board)
	if spot == nil {
		t.Error("spot should'nt be nil :(")
	}
	if spot[0] != 0 && spot[1] != 1 {
		t.Errorf("next empty spot should be at row %d and column %d",
			spot[0], spot[1])
	}
}

func TestCanPut(t *testing.T) {
	board := fromStr("000000000000000000000000000000000000000000000000000000000000000000000000000000000")
	if !canPut(board, []int{0, 0}, 1) {
		t.Error("can put with empty board not working")
	}

	board[0][0] = 1
	if canPut(board, []int{0, 1}, 1) {
		t.Error("same row number")
	}

	board[0][0] = 0
	board[1][0] = 1
	if canPut(board, []int{0, 0}, 1) {
		t.Error("same column number")
	}

	board[0][0] = 0
	board[1][0] = 0
	board[1][1] = 1
	if canPut(board, []int{0, 0}, 1) {
		t.Error("same square number")
	}
}

func TestProcessBatch(t *testing.T) {
	input := bytes.NewBufferString(sudokuExample)
	var output bytes.Buffer

	processBatch(input, &output)

	if strings.TrimSpace(output.String()) != strings.TrimSpace(expected) {
		t.Errorf("output should be %s but was %s", expected, output.String())
	}

}
