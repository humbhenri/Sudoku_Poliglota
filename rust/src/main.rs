
const ROW_SIZE: usize = 9;

#[derive(Debug)]
struct Board([[u32; ROW_SIZE]; ROW_SIZE]);

impl Board {
    fn from_str(sudoku: &str) -> Board {
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
        Board(board)
    }
}

fn main() {
    let sudoku_example = "200000060000075030048090100000300000300010009000008000001020570080730000090000004";
    let board = Board::from_str(sudoku_example);
    println!("{:?}", board)
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
