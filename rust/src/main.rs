use std::fmt;

const ROW_SIZE: usize = 9;

#[derive(Debug)]
struct Sudoku([[u32; ROW_SIZE]; ROW_SIZE]);

impl Sudoku {
    fn from_str(sudoku: &str) -> Sudoku {
        let mut board = [[0; ROW_SIZE]; ROW_SIZE];
    let mut row = 0;
    let mut col = 0;
    for c in sudoku.chars() {
        board[row][col] = c.to_digit(10).unwrap();
        col += 1;
        if col == ROW_SIZE {
            col = 0;
            row += 1;
        }
    }
    Sudoku(board)
    }

    fn can_put(&self, row: usize, column: usize, val: u32) -> bool {
        for x in 0..ROW_SIZE {
            if self.0[row][x] == val || self.0[x][column] == val {
                return false;
            }
        }
        let a = row-(row%3);
        let b = column-(column%3);
        for x in a..a+3 {
            for y in b..b+3 {
                if self.0[x][y] == val { return false; }
            }
        }
        true
    }

    fn next_empty_spot(&self) -> Option<(usize, usize)> {
        for row in 0..ROW_SIZE {
            for column in 0..ROW_SIZE {
                if self.0[row][column] == 0 {
                    return Some((row, column));
                }
            }
        }
        None
    }

    fn solve(&mut self) {
        let (row, column) = match self.next_empty_spot() {
            Some(m) => m,
            None => return,
        };
        for val in 1..9 {
            if self.can_put(row, column, val) {
                self.0[row][column] = val;
                self.solve();
                if self.next_empty_spot().is_none() {
                    return;
                }
            }
        }
        self.0[row][column] = 0;
    }
}

impl fmt::Display for Sudoku {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s: String = String::new();
        for row in self.0.iter() {
            s.push_str(
                &row.iter().map(|&x| x.to_string()).collect::<Vec<String>>().join(" "));
            s.push_str("\n");
        }
        write!(f, "{}", s)
    }
}

fn main() {
    let sudoku_example = "200000060000075030048090100000300000300010009000008000001020570080730000090000004";
    let mut board = Sudoku::from_str(sudoku_example);
    board.solve();
    println!("{}", board);
    for i in 1..4 { println!("{}", i); }
}

// #[cfg(test)]
// mod tests {
//     use super::*;

//     #[test]
//     fn read_sudoku_string_to_struct() {
//         let sudoku_example = "200000060000075030048090100000300000300010009000008000001020570080730000090000004";
//         println!("{:?}", board)
//     }
// }
