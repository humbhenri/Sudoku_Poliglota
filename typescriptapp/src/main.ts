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
        
    }
}

export = Sudoku;