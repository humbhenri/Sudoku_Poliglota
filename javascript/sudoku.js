// Solve a sudoku using backtrack
const assert = require("assert");

const ROW_SIZE = 9;

class Sudoku {
  #board;

  constructor(text) {
    this.#board = new Array();
    for (let k = 0; k < ROW_SIZE; k++) {
      this.#board[k] = new Array();
    }
    let i = 0;
    let j = 0;
    for (let k = 0; k < text.length; k++) {
      if (!isNaN(text.charAt(k)) && i < ROW_SIZE && j < ROW_SIZE) {
        this.#board[i][j] = parseInt(text.charAt(k));
        i = j == ROW_SIZE - 1 ? i + 1 : i;
        j = (j + 1) % ROW_SIZE;
      }
    }
  }

  toString() {
    const result = new Array();
    for (let i = 0; i < this.#board.length; i++) {
      result[i] = this.#board[i].join(" ");
    }
    return result.join("\n");
  }

  nextEmpty() {
    for (let i = 0; i < this.#board.length; i++) {
      for (let j = 0; j < this.#board.length; j++) {
        if (this.#board[i][j] == 0) {
          return [i, j];
        }
      }
    }
    return null;
  }

  canPut(x, y, val) {
    for (let i = 0; i < ROW_SIZE; i++) {
      if (this.#board[x][i] == val) return false; // row test
      if (this.#board[i][y] == val) return false; // column test
    }
    // square test
    let sqX = x - (x % 3);
    let sqY = y - (y % 3);
    for (let i = sqX; i < sqX + 3; i++) {
      for (let j = sqY; j < sqY + 3; j++) {
        if (this.#board[i][j] == val) return false;
      }
    }
    return true;
  }

  solve() {
    let spot = this.nextEmpty();
    if (spot) {
      let x = spot[0];
      let y = spot[1];
      for (let val = 1; val < 10; val++) {
        if (this.canPut(x, y, val)) {
          this.#board[x][y] = val;
          this.solve();
          if (!this.nextEmpty()) {
            // solution found
            return;
          }
        }
      }
      // solution not found, backtracking
      this.#board[x][y] = 0;
    }
  }
}

// tests
(function () {
  const sudoku = new Sudoku(
    "200000060000075030048090100000300000300010009000008000001020570080730000090000004"
  );
  assert.deepEqual(sudoku.nextEmpty(), [0, 1]);
  assert.ok(sudoku.canPut(0, 1, 1));
  sudoku.solve();
  assert.ok(!sudoku.nextEmpty());
})();

// progress bar
var util = require("util");
function loadBar(step, totalSteps, resolution, width) {
  if (
    parseInt(totalSteps / resolution) != 0 &&
    step % parseInt(totalSteps / resolution) == 0
  ) {
    ratio = step / totalSteps;
    count = parseInt(ratio * width);
    process.stdout.write(util.format("%d%% [", parseInt(ratio * 100)));
    for (var i = 0; i < count; i++) {
      process.stdout.write("=");
    }
    for (var i = count + 1; i < width; i++) {
      process.stdout.write(" ");
    }
    process.stdout.write("]\r");
  }
}

// read entire sudokus into memory
const fs = require("fs");
const path = require("path");
const input = process.argv[2];
if (!input) {
  console.log("Input file necessary");
  return;
}
fs.readFile(input, "ascii", function (err, data) {
  if (err) {
    console.log(err);
    return;
  }
  let before = new Date().getTime();

  let result = "";

  // solve all sudokus
  let lines = data.replace(/^\s+|\s+$/g, "").split("\n");
  let total = lines.length;
  for (let i = 0; i < total; i++) {
    let sudoku = new Sudoku(lines[i]);
    sudoku.solve();
    result = result + sudoku.toString() + "\n\n";
    loadBar(i, total, 20, 50);
  }

  let after = new Date().getTime();

  // write solution to file
  let output = path.basename(input);
  fs.writeFile("solved_" + output, result, function (err) {
    if (!err) {
      console.log(" --Elapsed time: %d ms", after - before);
    } else {
      console.log(`Error: ${err}`);
    }
  });
});
