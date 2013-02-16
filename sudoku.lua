-- Sudoku solving using backtrack
-- Unit testing starts

ROW_SIZE = 9

-- progress bar
function load_bar(step, total_steps, resolution, width)
   if math.floor(total_steps/resolution) == 0 then
      return
   end
   if step % math.floor(total_steps/resolution) ~= 0 then
      return
   end
   ratio = step/total_steps
   count = math.floor(ratio * width)
   io.write(string.format("%3d%% [", math.floor(ratio * 100)))
   for i=1, count do
      io.write("=")
   end
   for i=count, width-1 do
      io.write(" ")
   end
   io.write("]\r")
   io.flush()
end


-- split a string by a separator
function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end


-- get a 2D array sudoku from a 81 character string
function from_str(text)
	local board = {}
	for i=1, #text, ROW_SIZE do
		local row = {}
		for c in string.gmatch(text:sub(i, i+ROW_SIZE-1), ".") do
			table.insert(row, tonumber(c))
		end
		table.insert(board, row)
	end
	return board
end


-- pretty print a sudoku
function to_str(sudoku)
	local board = ""
	for i=1, #sudoku do
		for j=1, #sudoku[i] do
			board = board .. sudoku[i][j] .. " "
		end
		board = board .. "\n"
	end
	board = board .. "\n"
	return board
end

function next_empty(a_sudoku)
	for i=1, #a_sudoku do
		for j=1, #a_sudoku[i] do
			if a_sudoku[i][j] == 0 then
				return {i, j}
			end
		end
	end
	return nil
end


function can_put(a_sudoku, row, col, val)
	for x=1, ROW_SIZE do
		if a_sudoku[row][x] == val then return false end -- test row
		if a_sudoku[x][col] == val then return false end -- test column
	end
        local row_ = row-1
        local col_ = col-1
	local a, b = row_-(row_%3), col_-(col_%3)
	for i=a, a+2 do
		for j=b, b+2 do
			if a_sudoku[i+1][j+1] == val then return false end -- test square
		end
	end
	return true
end

function solve(sudoku)

	local spot = next_empty(sudoku)
	if spot then
		local x, y = spot[1], spot[2]
		for val=1, 9 do
			if can_put(sudoku, x, y, val) then
				sudoku[x][y] = val
				local new_sudoku = solve(sudoku)
				if next_empty(new_sudoku) == nil then
					-- solution found
					return new_sudoku
				end
			end
		end
		-- solution not found, backtrack
		sudoku[x][y] = 0
	end
	return sudoku
end


-- Read sudokus into memory
inputname = arg[1] or 'input_small.txt'
f = io.input(inputname)
data = io.read('*a')
f:close()

-- Solve all sudokus
before = os.time()
lines = data:split("\n")
total = #lines
solved = 0
result = ''
for i=1, #lines do
	result = result .. to_str(solve(from_str(lines[i])))
    solved = solved + 1
    load_bar(solved, total, 20, 50)
end

-- present time
print('-- Elapsed time ' .. (os.time() - before) .. ' s')

-- write solutions to file
f = io.output('solved_' .. inputname)
f:write(result)
f:close()
