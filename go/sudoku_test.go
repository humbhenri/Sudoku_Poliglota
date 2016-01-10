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
	sudoku := fromStr(sudokuExample)
	sudoku.solve()

	if sudoku.String() != expected {
		t.Errorf("Resolved was %s but should be %s", sudoku, expected)
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
