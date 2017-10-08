# TODO

defmodule Sudoku do
  defp to_int(v) do
    v - 48
  end

  def row_column(idx) do
    {div(idx, 9), rem(idx, 9)}
  end

  def read_input(str) do
    Enum.with_index(str) 
    |> Map.new(fn({v, idx}) -> {row_column(idx), to_int(v)} end)
  end

  def next_empty(sudoku) do
    case (Enum.find sudoku, fn({_, v}) -> v == 0 end) do
      {idx, _} -> idx
      _ -> nil
    end
  end

  def row(sudoku, n) do
    Enum.filter(sudoku, fn({{i, _}, _}) -> i==n end) 
    |> Enum.map(fn({_, v}) -> v end)
  end

  def column(sudoku, n) do
    Enum.filter(sudoku, fn({{_, j}, _}) -> j==n end) 
    |> Enum.map(fn({_, v}) -> v end)
  end

  def square(sudoku, x, y) do
    for a <- Stream.iterate(x-rem(x, 3), &(&1+1)) |> Enum.take(3),
      b <- Stream.iterate(y-rem(y, 3), &(&1+1)) |> Enum.take(3),
      do: Map.get(sudoku, {a, b})
  end

  def can_put(sudoku, x, y, n) do
    all_diff_n = fn(xs) -> Enum.all(xs, &(&1 != n)) end

    row(sudoku, y) |> all_diff_n.()
    and column(sudoku, x) |> all_diff_n.()
    and square(sudoku, x, y) |> all_diff_n.()
  end

  def pretty(sudoku) do
    sudoku
    |> Enum.chunk_every(3) 
    |> Enum.chunk_every(3) # 9x9 matrix
    |> Enum.map(&(Enum.join(&1, " "))) # space between every 3 digits in each row
    |> Enum.chunk_every(3) 
    |> Enum.map(&(Enum.join(&1, "\n"))) 
    |> Enum.join("\n\n") # double new line every 3 rows
    |> IO.puts
  end
end
