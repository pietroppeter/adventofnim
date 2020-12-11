import nimib, animu
nbInit
nbText: "## 2020, Day 11: Seating System"

nbText: """standard day with a grid. Highlights:
* a clean refactoring after part1 to solve part2
* ran into an expected issue when copying a sequence inside a proc (fixed with Orc, see: [forum](https://forum.nim-lang.org/t/7241))
"""

nbCode:
  import strutils, nimoji

  when defined(gcOrc):
    echo "using Orc :japanese_ogre:".emojize

nbText: "First we parse and show the example grid."

nbCode:
  type
    SeatGridKind = enum
      sgFloor = ".", sgEmpty = "L", sgOccupied = "#"
    SeatGrid = object
      data: seq[SeatGridKind]
      ncols: int

  let example = """L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL""".replace("\r", "")  # I have had issues before (with the input)

  proc parse(text: string): SeatGrid =
    for i, c in text:
      case c:
        of '.':
          result.data.add sgFloor
        of 'L':
          result.data.add sgEmpty
        of '\n':
          if result.ncols == 0:
            result.ncols = result.data.len
          elif result.data.len mod result.ncols != 0:
            echo "ERROR expect same number of columns ", i, " ", c
        else:
          echo "ERROR cannot parse ", i, " ", c

  proc `$`(g: SeatGrid): string =
    for i, d in g.data:
      result.add:
        case d:
          of sgFloor:
            "."
          of sgEmpty:
            "L"
          of sgOccupied:
            "#"
      if (i + 1) mod g.ncols == 0:
        result.add "\n"

  var exGrid = parse example
  echo exGrid

  func nrows(g: SeatGrid): int =
    g.data.len div g.ncols

  echo exGrid.nrows # 10

nbText: "now we define a function to get adjacent indices. In part 2 we refactored this to use a `dir` function:"
nbCode:
  when defined(part1):
    iterator adjIdx(i: int, g: SeatGrid): int =
      if i >= g.ncols: ## not first row
        yield i - g.ncols ## up
      if i >= g.ncols and (i + 1) mod g.ncols != 0: ## .. and not last column
        yield i - g.ncols + 1 ## up-right
      if (i + 1) mod g.ncols != 0: ## not last column
        yield i + 1 ## right
      if (i + 1) mod g.ncols != 0 and (i + g.ncols) < g.data.len: ## .. and not last row
        yield i + g.ncols + 1 ## right-down
      if (i + g.ncols) < g.data.len: ## not last row
        yield i + g.ncols ## down
      if (i + g.ncols) < g.data.len and i mod g.ncols != 0: ## .. and not first column
        yield i + g.ncols - 1 ## down-left
      if i mod g.ncols != 0: ## not first column
        yield i - 1 ## left
      if i mod g.ncols != 0 and i >= g.ncols: ## .. and not first row
        yield i - g.ncols - 1 ## left-up
  else:
    # refactor adjIdx for part2
    type Direction = enum
      up, upright, right, rightdown, down, downleft, left, leftup

    func dir(i: int, d: Direction, g: SeatGrid): (bool, int) =
      result = (false, i)
      case d:
        of up:
          if i >= g.ncols: ## not first row
            result = (true, i - g.ncols) ## up
        of upright:
          if i >= g.ncols and (i + 1) mod g.ncols != 0: ## .. and not last column
            result = (true, i - g.ncols + 1) ## up-right
        of right:
          if (i + 1) mod g.ncols != 0: ## not last column
            result = (true, i + 1 ) ## right
        of rightdown:
          if (i + 1) mod g.ncols != 0 and (i + g.ncols) < g.data.len: ## .. and not last row
            result = (true, i + g.ncols + 1) ## right-down
        of down:
          if (i + g.ncols) < g.data.len: ## not last row
            result = (true, i + g.ncols) ## down
        of downleft:
          if (i + g.ncols) < g.data.len and i mod g.ncols != 0: ## .. and not first column
            result = (true, i + g.ncols - 1) ## down-left
        of left:
          if i mod g.ncols != 0: ## not first column
            result = (true, i - 1) ## left
        of leftup:
          if i mod g.ncols != 0 and i >= g.ncols: ## .. and not first row
            result = (true, i - g.ncols - 1) ## left-up

    iterator adjIdx(i: int, g: SeatGrid): int =
      var r = (false, 0)
      for d in Direction:
        r = dir(i, d, g)
        if r[0]:
          yield r[1]

  for i in [0, 5, 9, 40, 45, 49, 90, 95, 99]:
    echo "adjIdx ", i
    for j in adjIdx(i, exGrid):
      echo "  ", j

nbText: "a `step` proc to solve part1. this is where I ran in the _issue_"
nbCode:
  proc step(g: var SeatGrid): int =
    when defined(gcOrc): ## let data would not work with gcRefc see: https://forum.nim-lang.org/t/7241
      let data = g.data ## snapshot of grid
    else:
      var data = g.data
    var numOcc: int
    for i in 0 .. g.data.high:
      numOcc = 0
      for j in adjIdx(i, g):
        if data[j] == sgOccupied:
          inc numOcc
      if data[i] == sgEmpty and numOcc == 0:
        g.data[i] = sgOccupied
        inc result
      elif data[i] == sgOccupied and numOcc >= 4:
        g.data[i] = sgEmpty
        inc result

  func countOcc(g: SeatGrid): int =
    for s in g.data:
      if s == sgOccupied:
        inc result

  var i = 1
  while step(exGrid) > 0:
    echo "step: ", i
    echo exGrid
    inc i
  echo "numOcc: ", countOcc(exGrid) ## 37

  let input = "2020/input11.txt".readFile.replace("\r", "")
  var inpGrid = parse input
  echo (inpGrid.ncols, inpGrid.nrows)
  i = 1
  while step(inpGrid) > 0:
    inc i
  echo "stops at step: ", i ## 98
  echo "numOcc: ", countOcc(inpGrid) ## 2334

gotTheStar

nbText: "and a `step2` proc to solve part2"
nbCode:
  when not defined(part1):
    echo "\n---Part2---\n"

    proc step2(g: var SeatGrid): int =
      when defined(gcOrc): ## let data would not work with gcRefc see: https://forum.nim-lang.org/t/7241
        let data = g.data ## snapshot of grid
      else:
        var data = g.data
      var numOcc: int
      var r = (false, 0)
      for i in 0 .. g.data.high:
        numOcc = 0
        for d in Direction:
          r = dir(i, d, g)
          while r[0] and data[r[1]] == sgFloor:
            r = dir(r[1], d, g)
          if r[0] and data[r[1]] == sgOccupied:
            inc numOcc
        if data[i] == sgEmpty and numOcc == 0:
          g.data[i] = sgOccupied
          inc result
        elif data[i] == sgOccupied and numOcc >= 5:
          g.data[i] = sgEmpty
          inc result

    i = 1
    exGrid = parse example
    while step2(exGrid) > 0:
      echo "step: ", i
      echo exGrid
      inc i
    echo "numOcc: ", countOcc(exGrid) ## 26

    inpGrid = parse input
    i = 1
    while step2(inpGrid) > 0:
      inc i
    echo "stops at step: ", i ## 86
    echo "numOcc: ", countOcc(inpGrid) ## 2100

gotTheStar
nbSave