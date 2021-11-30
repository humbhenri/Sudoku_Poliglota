# Sudoku solver using backtrack

BOARD_SIZE = 9

# progress bar
def load_bar step, total_steps, resolution, width
  while total_steps/resolution == 0
    total_steps *= 10
    step *= 10
  end
  return if step % (total_steps/resolution) != 0
  ratio = step.to_f/total_steps
  count = (ratio*width).to_i
  printf "%3d%% [", (ratio*100).to_i
  count.times { printf "="}
  (width-count).times { printf " "}
  printf "] #{step}/#{total_steps}\r"
  $stdout.flush
end

# line -> sudoku
def from_str line
  i, j = 0, 0
  sudoku = Array.new BOARD_SIZE
  sudoku.map! { Array.new BOARD_SIZE, 0}
  line.each_byte do |c|
    if c-48 >= 0 and c-48 <=9
      sudoku[i][j] = c-48
      if j == BOARD_SIZE - 1
        i += 1 % BOARD_SIZE
        j = 0
      else
        j += 1 % BOARD_SIZE
      end
    end
  end
  sudoku
end

# sudoku -> string
def to_str sudoku
  text = ""
  sudoku.each do |row|
    row.each do |e|
      text << e.to_s << " "
    end
    text << "\n"
  end
  text << "\n"
end

def next_empty sudoku
  for i in 0..BOARD_SIZE-1
    for j in 0..BOARD_SIZE-1
      return [i, j] if sudoku[i][j] == 0
    end
  end
  nil
end

def can_put? sudoku, i, j, val
  for x in 0..BOARD_SIZE-1
    return false if sudoku[x][j] == val
    return false if sudoku[i][x] == val
  end
  a, b = i-(i%3), j-(j%3)
  for x in a..a+2
    for y in b..b+2
      return false if sudoku[x][y] == val
    end
  end
  true
end

def solve sudoku
  spot = next_empty sudoku
  return sudoku unless spot
  x, y = spot
  for i in 1..9
    if can_put? sudoku, x, y, i
      sudoku[x][y] = i
      new_sudoku = solve(sudoku)
      return new_sudoku unless next_empty new_sudoku
    end
  end
  sudoku[x][y] = 0
  sudoku
end

# read entire sudokus into memory
if ARGV.length == 0
  puts 'Must insert an input file.'
  exit!
end

data = ""
input = ARGV[0]
File.open(input, "r") do
  |file|
  data = file.read
end

result = ""
before_all = Time.now
lines = data.split "\n"
total = lines.length

# solve all sudokus
lines.each_with_index do
  |line, index|
  sudoku = from_str line
  result << to_str(solve(sudoku))
  load_bar index, total, 20, 50
end

elapsed_s = Time.now - before_all

# present results
puts "--Elapsed: #{elapsed_s} s"

# write solutions to file
output = 'Solved_' + File.basename(input)
File.open(output, "w") do |file|
  file.write result
end
