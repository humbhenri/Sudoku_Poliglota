import sequtils, sugar, options, os, posix, times, strutils, std/strformat

type
  ValidNumber = 0..9
  Row = 1..9
  Col = 1..9
  Sudoku = array[Row, array[Col, ValidNumber]]
  Pos = tuple[row: Row, column: Col]
  Progress = object
    step: int
    total: int
    width: int

func newSudoku(s: string): Sudoku =
  var i = 1
  var j = 1
  var sudoku: Sudoku
  for c in s:
    sudoku[i][j] = int(c) - 48
    j += 1
    if j > 9:
      j = 1
      i += 1
  sudoku

func nextEmpty(s: Sudoku): Option[Pos] =
  for i in 1..9:
    for j in 1..9:
      if s[i][j] == 0:
        return some((Row(i), Col(j)))

func column(s: Sudoku, c: Col): seq[ValidNumber] =
  collect(newSeq):
    for r in s:
      r[c]

proc region(s: Sudoku, p: Pos): seq[ValidNumber] =
  let x = p.row-1
  let y = p.column-1
  var i = (x - (x mod 3)) + 1
  var j = (y - (y mod 3)) + 1
  collect(newSeq):
    for a in i..(i+2):
      for b in j..(j+2):
        s[a][b]

proc canPut(s: Sudoku, p: Pos, v: ValidNumber): bool =
  not (v in s[p.row]) and
  not (v in s.column(p.column)) and
  not (v in s.region(p))

proc `$`(s: Sudoku): string =
  let rowToString = proc(row: array[Col, ValidNumber]): string =
    join(row, " ")
  join(map(s, rowToString), "\n")

proc solve(s: var Sudoku) =
  let place = s.nextEmpty
  if place.isNone:
    return
  for i in 1..9:
    if s.canPut(place.get(), i):
      s[place.get().row][place.get().column] = i
      s.solve
      if s.nextEmpty.isNone:
        return
  s[place.get().row][place.get().column] = 0 # backtracking

template benchmark(code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time ", elapsedStr, "s"

proc `$`(p: Progress): string =
  let ratio = p.step / p.total
  let count = ratio * float(p.width)
  let fill = "=".repeat int(count)
  let rest = " ".repeat (p.width - int(count))
  fmt"{ratio*100:.2f}% [{fill}{rest}]"

proc processInput(file: string) =
  let input = open(file)
  let output = open("solved_" & $basename(file), fmWrite)
  var entries = newSeq[string]()
  defer:
    input.close()
    output.close()
  while not(input.endOfFile):
    entries.add(input.readLine)
  var progress = Progress(step: 0, total: entries.len, width: 50)
  for entry in entries:
    var s = newSudoku(entry)
    s.solve
    output.writeLine $s & "\n"
    progress.step = progress.step + 1
    write(stdout, "\r", progress)
    flushFile(stdout)
  echo ""

if commandLineParams().len > 0:
  var file = commandLineParams()[0]
  benchmark:
    processInput file
else:
  echo "input file is required"

