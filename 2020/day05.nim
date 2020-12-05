import parseutils, strutils, macros, algorithm, bitops, strformat, sets

type Seat = int16

# make it colored, returns bool but discardable, debugEcho behind a compile switch
macro chk(val, exp: untyped)  =
  let
    v = val.toStrLit
  quote do:
    let outcome = if `val` == `exp`: "OK" else: "KO"
    debugEcho "[", outcome, "] ", `v`, " = ", `val`, "; expected = ", `exp`

proc parseSeat(s: string): Seat =
  discard parseBin[int16](s.multiReplace([
    ("F", "0"), ("B", "1"), ("R", "1"), ("L", "0")
  ]), result)

chk parseSeat("FBFBBFFRLR"), 357

proc row(x: Seat): int = x shr 3
proc col(x: Seat): int =
  result = x.int
  result.mask(0b111)

chk parseSeat("FBFBBFFRLR").row, 44
chk parseSeat("FBFBBFFRLR").col, 5

proc parseSeats(text: string): (seq[Seat], int, int, int) =
  var
    seats: seq[Seat]
    maxSeat = 0
    minRow = 0
    maxRow = 1000
  for line in text.splitLines:
    seats.add parseSeat(line)
    if seats[^1] > maxSeat:
      maxSeat = seats[^1]
    if seats[^1].row < minRow:
      minRow = seats[^1].row
    if seats[^1].row > maxRow:
      maxRow = seats[^1].row
  (seats, maxSeat, minRow, maxRow)    

let (seats, maxSeat, minRow, maxRow) = parseSeats("2020/input05.txt".readFile)
chk(maxSeat, 947)

proc findMine(s: seq[Seat]; minRow, maxRow: int) =
  var s = s
  s.sort()
  for x in 1 ..< s.len:
    if s[x] != s[x - 1] + 1 and s[x].row > minRow and s[x].row < maxRow:
      echo "my seat: ", s[x]

seats.findMine(minRow, maxRow) # 637: too high

type
  Pass = tuple[row, col: int]
  Passes = HashSet[Passes]

proc toPasses(s: seq[Seat]): Passes =
  for x in s:
    result.add (x.row, x.col)

proc show(s: Passes) =
  var text = "    01234567\n"
  for row in 0 .. 127:
    text.add &"{row:03} "
    for col in 0 .. 7:
      if (row, col) in s:
        text.add "X"
      else:
        text.add "."
    text.add "\n"
  text.add "\n"
  echo text

seats.toPasses.show