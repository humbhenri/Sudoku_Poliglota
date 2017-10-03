# TODO

defmodule Sudoku do
    defp to_int(v) do
        v - 48
    end

    def line_column(idx) do
        {div(idx, 9), rem(idx, 9)}
    end

    def read_input(str) do
         Stream.with_index(str) |> 
         Stream.map(fn({v, idx}) -> {to_int(v), line_column(idx)} end) 
    end

    def next_empty(sudoku) do
        Stream.filter(sudoku, fn({v, idx}) -> v == 0 end)
        Stream.take(1) |> 
        Stream.map(fn({v, idx}) -> idx end)
        Enum.to_list |> 
        List.first
    end

    def line(sudoku, n) do
        Stream.filter(sudoku, fn({v, {i, j}}) -> i == n end) 
    end

    def column(sudoku, n) do
        Stream.filter(sudoku, fn({v, {i, j}}) -> j == n end) 
    end

    def square(sudoku, i, j) do
    end
end