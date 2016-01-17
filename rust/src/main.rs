use std::fmt;

const ROW_SIZE: usize = 9;

#[derive(Debug)]
pub struct Sudoku([[u32; ROW_SIZE]; ROW_SIZE]);

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
        for val in 1..10 {
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
    let sudoku_example = "807000003602080000000200900040005001000798000200100070004003000000040108300000506";
    let mut board = Sudoku::from_str(sudoku_example);
    board.solve();
    println!("{}", board);
}

#[cfg(test)]
mod tests {
    use super::*;

    const SUDOKU_EXAMPLE: & 'static str = "200000060000075030048090100000300000300010009000008000001020570080730000090000004";

    #[test]
    fn test_create_sudoku() {
        assert_eq!("2 0 0 0 0 0 0 6 0
0 0 0 0 7 5 0 3 0
0 4 8 0 9 0 1 0 0
0 0 0 3 0 0 0 0 0
3 0 0 0 1 0 0 0 9
0 0 0 0 0 8 0 0 0
0 0 1 0 2 0 5 7 0
0 8 0 7 3 0 0 0 0
0 9 0 0 0 0 0 0 4
",  Sudoku::from_str(SUDOKU_EXAMPLE).to_string());
    }

    #[test]
    fn test_next_empty() {
        let board = Sudoku::from_str(SUDOKU_EXAMPLE);
        assert_eq!(Some((0, 1)), board.next_empty_spot());
    }

    #[test]
    fn test_can_put() {
        let board = Sudoku::from_str(SUDOKU_EXAMPLE);
        assert!(board.can_put(0, 1, 7));
    }

    #[test]
    fn test_solve() {
        let mut board = Sudoku::from_str(SUDOKU_EXAMPLE);
        board.solve();
        assert_eq!("2 7 3 4 8 1 9 6 5
9 1 6 2 7 5 4 3 8
5 4 8 6 9 3 1 2 7
8 5 9 3 4 7 6 1 2
3 6 7 5 1 2 8 4 9
1 2 4 9 6 8 7 5 3
4 3 1 8 2 9 5 7 6
6 8 5 7 3 4 2 9 1
7 9 2 1 5 6 3 8 4
", board.to_string());
    }
}
