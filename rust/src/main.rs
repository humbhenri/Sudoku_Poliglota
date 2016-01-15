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
    let board = Sudoku::from_str(sudoku_example);
    println!("{}", board)
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
