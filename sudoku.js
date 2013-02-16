// Solve a sudoku using backtrack

var ROW_SIZE = 9

// return a sudoku from a 81 character line
function fromStr(text) {
	var sudoku = new Array();
	for (var k = 0; k<ROW_SIZE; k++) { sudoku[k] = new Array(); }
	var i = 0;
	var j = 0;
	for (var k = 0; k < text.length; k++) {
		if (! isNaN(text.charAt(k)) && i < ROW_SIZE && j < ROW_SIZE) {
			sudoku[i][j] = parseInt(text.charAt(k));
			i = j == ROW_SIZE - 1 ? i+1 : i;
			j = (j + 1) % ROW_SIZE;
		}
	}
	return sudoku;
}

// string representation from a sudoku 
function toStr(sudoku) {
	var result = new Array();
	for (var i=0; i<sudoku.length; i++) {
		result[i] = sudoku[i].join(" ");
	}
	return result.join("\n");
}

// return next spot where value is zero
function nextEmpty(sudoku) {
	for (var i=0; i<sudoku.length; i++) {
		for (var j=0; j<sudoku.length; j++) {
			if (sudoku[i][j] == 0) {
				return [i, j];
			}
		}
	}
	return null;
}

// return true if the element can be put at the specified spot
function canPut(sudoku, x, y, val) {
	for (var i=0; i<ROW_SIZE; i++) {
		if (sudoku[x][i] == val) return false; // row test
		if (sudoku[i][y] == val) return false; // column test
	}
	// square test
	var sqX = x-(x%3);
    var sqY = y-(y%3);
    for (var i=sqX; i<sqX+3; i++) {
    	for (var j=sqY; j<sqY+3; j++) {
    		if (sudoku[i][j] == val) return false;
    	}
    }
    return true;
}

// return a solved sudoku, or the argument if cannot find the solution
function solve(sudoku) {
	var spot = nextEmpty(sudoku);
	if (spot) {
		var x = spot[0];
		var y = spot[1];
		for (var val=1; val<10; val++) {
			if (canPut(sudoku, x, y, val)) {
				sudoku[x][y] = val;
				newSudoku = solve(sudoku);
				if (! nextEmpty(newSudoku)) {
					// solution found
					return newSudoku;
				}
			}
		}
		// solution not found, backtracking
		sudoku[x][y] = 0;
	}
	return sudoku;
}

// progress bar
var util = require('util');
function loadBar(step, totalSteps, resolution, width) {
	if (parseInt(totalSteps/resolution) != 0 && (step % parseInt(totalSteps/resolution) == 0)) {
		ratio = step/totalSteps;
		count = parseInt(ratio * width);
		process.stdout.write(util.format('%d%% [', parseInt(ratio * 100)));
		for (var i=0; i<count; i++) { process.stdout.write('='); }
		for (var i=count+1; i<width; i++) { process.stdout.write(' '); }
		process.stdout.write(']\r');
	}
}

// read entire sudokus into memory
var fs = require('fs');
var input = process.argv[2];
fs.readFile(input, 'ascii', function(err, data) {

	var before = new Date().getTime();

	var result = "";

	// solve all sudokus
	var lines = data.replace(/^\s+|\s+$/g, '').split("\n");
	var total = lines.length;
	for (var i=0; i<total; i++) {
		var sudoku = fromStr(lines[i]);
		result = result + toStr(solve(sudoku)) + "\n\n";
		loadBar(i, total, 20, 50);
	}

	var after = new Date().getTime();

	// write solution to file
	fs.writeFile('solved_' + input, result, function(err) {
		if (!err) {
			console.log(" --Elapsed time: %d ms", after - before);
		}
	});
});