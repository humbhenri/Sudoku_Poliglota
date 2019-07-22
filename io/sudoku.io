
// a sudoku of size 9x9
Sudoku := Object clone
Sudoku init := method(
	self rowSize := 9;
	self board := Range 1 to(self rowSize) map(Range 1 to(self rowSize) map(0))
)

Sudoku toStr := method(self board map(join(" ")) join("\n"))

// 81 char string to a sudoku board
Sudoku fromStr := method(str,
	i := 0;
	j := 0;
	str foreach(char, 
		self board at(i) atPut(j, char-48);
		if(j == self rowSize - 1, i = i + 1 % self rowSize; j = 0, j = j + 1 % self rowSize)
	)
)

Sudoku nextEmpty := method(
	Range 0 to(self rowSize - 1) foreach(i,
		Range 0 to(self rowSize - 1) foreach(j,
			if(self board at(i) at(j) == 0, return list(i,j))
		)
	)
	return nil
)

Sudoku canPut := method(row, column, val,
	
	if(self board at(row) contains(val), return false,					// test row
		if(self board map(at(column)) contains(val), return false,    	// test column
			a := row - (row%3);
			b := column - (column%3);
			self board slice(a, a+3) foreach(row, 
				if (row slice(b, b+3) contains(val), return false)) 	// test square
		)
	)
	return true
)

Sudoku solve := method(
	spot := self nextEmpty;
	if(spot, 
		x := spot at(0);
		y := spot at(1);
		Range 1 to(9) foreach(val,
			if(self canPut(x,y,val), 
				self board at(x) atPut(y, val);
				self solve;
				if(self nextEmpty not, return)		 					// solution found				
			)
		),
		self board at(x) atPut(y, 0)
	)
)

// Main program

// read entire file into memory

// entry := System args at(1)
// input := File open(entry) readToEnd 

// solve all sudokus
// lines := input split("\n")
// lines foreach(line,
// 	sudoku := Sudoku clone;
// 	sudoku fromStr(line);
// 	(sudoku toStr .. "\n") println;
// 	sudoku solve;
// 	(sudoku toStr .. "\n") println;
// )
s := Sudoku clone 
s fromStr("200000060000075030048090100000300000300010009000008000001020570080730000090000004")
Testing assertEqual(list(0, 1), s nextEmpty)
Testing assertTrue(s canPut(0, 1, 1))
Testing assertFalse(s canPut(0, 1, 2))

