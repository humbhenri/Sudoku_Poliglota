package main

import "testing"

const sudokuExample = "2000060000075030048090100000300000300010009000008000001020570080730000090000004"

func TestSolve(t *testing.T) {
	resolved := solve(FromStr(sudokuExample))
	expected := `2 7 3 4 8 1 9 6 5 
9 1 6 2 7 5 4 3 8 
5 4 8 6 9 3 1 2 7 
8 5 9 3 4 7 6 1 2 
3 6 7 5 1 2 8 4 9 
1 2 4 9 6 8 7 5 3 
4 3 1 8 2 9 5 7 6 
6 8 5 7 3 4 2 9 1 
7 9 2 1 5 6 3 8 4 
`
	if ToStr(resolved) != expected {
		t.Errorf("Resolved was %s but should be %s", ToStr(resolved), expected)
	}
}
