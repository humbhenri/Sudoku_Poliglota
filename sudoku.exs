# TODO

defmodule Sudoku do
    defp to_int(v) do
        v - 48
    end

    def line_column(idx) do
        {div(idx, 9), rem(idx, 9)}
    end

    def read_input(str) do
         Enum.with_index(str) 
         |> Map.new(fn({v, idx}) -> {line_column(idx), to_int(v)} end)
    end

    def next_empty(sudoku) do
        case (Enum.find sudoku, fn({_, v}) -> v == 0 end) do
        {idx, _} -> idx
        _ -> nil
        end
    end

    def line(sudoku, n) do
        Enum.filter(sudoku, fn({{i, _}, _}) -> i==0 end) 
    end

    def column(sudoku, n) do
        Enum.filter(sudoku, fn({{_, j}, _}) -> j==0 end)
    end

    def square(sudoku, i, j) do
    end
end
