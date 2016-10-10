class Sudoku {
    private static board_size: number = 9;
    private _board: number[][];
    
    constructor(oneliner: string) {
        let numbers = oneliner.split('').map(x => parseInt(x));
        this._board = [];
        while (numbers.length) this._board.push(numbers.splice(0, Sudoku.board_size));
    }

    get board() {
        return this._board;
    }

    solve(): void {
        this._board = this._solve(this._board);
    }

    private _solve(board: number[][]): number[][] {
        let spot = this._nextEmpty(board);
        if (!spot) return board;
        let [x, y] = spot;
        for (let val=1; val<=9; val++) {
            if (this._canPut(board, x, y, val)) {
                board[x][y] = val;
                let newBoard = this._solve(board);
                if (!this._nextEmpty(newBoard))
                    return newBoard;
            }
        }
        board[x][y] = 0;
        return board;
    }

    private _nextEmpty(board: number[][]): [number, number] {
        for (let i=0; i<Sudoku.board_size; i++) {
            for (let j=0; j<Sudoku.board_size; j++) {
                if (board[i][j] == 0) return [i, j];                
            }
        }
        return null;
    }

    private _canPut(board: number[][], x: number, y: number, val: number): boolean {
        for (let i=0; i<Sudoku.board_size; i++) {
            if (board[i][y] == val || board[x][i] == val) return false;
        }
        let squareX = x - (x%3);
        let squareY = y - (y%3);
        for (let i=squareX; i<squareX+3; i++) {
            for (let j=squareY; j<squareY+3; j++) {
                if (board[i][j] == val) return false;
            }
        }
        return true;
    }
}

export = Sudoku;