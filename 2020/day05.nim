import nimib, animu

nbInit
nbText: "# --- Day 5: Binary Boarding ---"
nbText: "parsing is straightforward, considering that encoding is basically binary"

nbCode:
  type Seat = int16

  proc parseSeat(s: string): Seat =
    discard parseBin[int16](s.multiReplace([
      ("F", "0"), ("B", "1"), ("R", "1"), ("L", "0")
    ]), result)

  chk parseSeat("FBFBBFFRLR"), 357

nbText: "if I want to get back row and col (I will use it for visualization at the end)"
nbCode:
  proc row(x: Seat): int = x shr 3
  proc col(x: Seat): int =
    result = x.int
    result.mask(0b111)

  chk parseSeat("FBFBBFFRLR").row, 44
  chk parseSeat("FBFBBFFRLR").col, 5

nbText: "_part1_ is solved during parsing input file"
nbCode:
  var
    maxSeat = 0
    seats: seq[Seat]
  for line in "2020/input05.txt".lines:
    seats.add parseSeat(line)
    if seats[^1] > maxSeat:
      maxSeat = seats[^1]
  echo "part1: ", maxSeat
  chk(maxSeat, 947)

gotTheStar

nbText: "_part 2_ is solved by sorting and finding the gap"
nbCode:
  var mySeat: Seat
  seats.sort()
  for x in 1 ..< seats.len:
    if seats[x] != seats[x - 1] + 1:
      mySeat = seats[x] - 1 ## first try I forgot the "- 1!
      break
  echo "part2: ", mySeat
  chk(maxSeat, 636)

gotTheStar

nbText: "what do we need to _visualize the plane_? I will convert Seat in (row, col)"
nbCode:
  type RowCol = tuple[row, col: int]

  proc toPasses(s: seq[Seat]): HashSet[RowCol] =
    for x in s:
      result.incl (x.row, x.col).RowCol

  proc showAndTell(s: HashSet[RowCol]): RowCol =
    var
      text = "____01234567\n" # I need to fix spaces at the beginning of pre!
    for row in 0 .. 127:
      text.add &"{row:03} "
      for col in 0 .. 7:
        if (row, col) in s:
          text.add "X"
        elif row < 30 or row > 100:  # I know my place is in the middle of the plane
          text.add "."
        else:
          text.add "<em>O</em>"
          result = (row, col)
      text.add "\n"
    text.add "\n"
    echo text

  let myRowCol = seats.toPasses.showAndTell
  
nbtext: "I can check back id"
nbCode:
  proc id(x: RowCol): int = x.col + 8*x.row
  chk id(myRowCol), mySeat

nbSave