/// <reference path="../typings/mocha/mocha.d.ts" />
/// <reference path="../typings/chai/chai.d.ts" />
import { expect } from "chai";
import Sudoku = require("./main");

describe('Sudoku', function() {

    let sudoku = new Sudoku('200000060000075030048090100000300000300010009000008000001020570080730000090000004');
    
    describe('fromStr', function() {
        
        it('should parse a one line sudoku in string format', function() {
            expect(sudoku.board).to.eql([
                [2, 0, 0, 0, 0, 0, 0, 6, 0],
                [0, 0, 0, 0, 7, 5, 0, 3, 0],
                [0, 4, 8, 0, 9, 0, 1, 0, 0],
                [0, 0, 0, 3, 0, 0, 0, 0, 0],
                [3, 0, 0, 0, 1, 0, 0, 0, 9],
                [0, 0, 0, 0, 0, 8, 0, 0, 0],
                [0, 0, 1, 0, 2, 0, 5, 7, 0],
                [0, 8, 0, 7, 3, 0, 0, 0, 0],
                [0, 9, 0, 0, 0, 0, 0, 0, 4]]);
        });

    });

    describe('solution', function() {

        it('should solve a sudoku giving the following response', function() {
            sudoku.solve();
            expect(sudoku.board).to.eql(
                  [[2, 7, 3, 4, 8, 1, 9, 6, 5],
                   [9, 1, 6, 2, 7, 5, 4, 3, 8],
                   [5, 4, 8, 6, 9, 3, 1, 2, 7],
                   [8, 5, 9, 3, 4, 7, 6, 1, 2],
                   [3, 6, 7, 5, 1, 2, 8, 4, 9],
                   [1, 2, 4, 9, 6, 8, 7, 5, 3],
                   [4, 3, 1, 8, 2, 9, 5, 7, 6],
                   [6, 8, 5, 7, 3, 4, 2, 9, 1],
                   [7, 9, 2, 1, 5, 6, 3, 8, 4]]);
        });
    });
});