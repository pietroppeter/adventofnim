import animu, nimib

nbInit(theme=useAdventOfNim)
nbText: """## Day 15: [Chiton](https://adventofcode.com/2021/day/15)

Today is about path search on a grid. I tend to struggle with these
since I never properly studied the theory.

### Part 1

We need to go from top left to bottom right minimizing sum of risk.
My strategy will be to create from given grid a new grid that
at every "node" (it usually pays to think of these problems in terms of graphs),
will tell me the direction I should come from in order to minimize the risk and
get there. The final path will be found by following directions from bottom right.

Here are the inputs:
"""
nbCode:
  let
    testInput = """
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581"""
    puzzleInput = readFile("2021/input15.txt")
nbText: """I will be using grid code from my Day09 (no blogpost published),
copying and pasting here the useful bits (I will need to think of an ergonomic
way to import from a notebook). I am also fine with having a sentinel value
for stuff outside the grid that is a high value.
"""
nbCode:
  type
    Coord = tuple[x, y: int]
    Grid[T] = object
      data: seq[T]
      yLen, xLen: int
      sentinel: T  # value for outside the grid
    GridInt = Grid[int]
    Dir = enum
      right, down, left, up

  func isOutside[T](c: Coord, g: Grid[T]): bool =
    c.x < 0 or c.x >= g.xLen or c.y < 0 or c.y >= g.yLen

  func toIndex[T](g: Grid[T], c: Coord): int =
    if c.isOutside(g):
      -1
    else:
      c.y*g.xLen + c.x

  func `[]`[T](g: Grid[T], c: Coord): T =
    let i = g.toIndex(c)
    if i < 0:
      g.sentinel
    else:
      g.data[i]

  func parseInt(c: char): int =
    result = ord(c) - ord('0')
    assert result >= 0 and result <= 9

  func parse(text: string): GridInt =
    # result.data = newSeqOfCap(text.len)
    for line in text.strip.splitLines:
      result.data.add line.toSeq.map(parseInt)
      inc result.yLen
      if result.xLen == 0:
        result.xLen = line.len
      else:
        assert line.len == result.xLen
    result.sentinel = int.high

  iterator coords[T](g: Grid[T]): Coord =
    for y in 0 ..< g.yLen:
      for x in 0 ..< g.xLen:
        yield (x, y)

  func `+`(c: Coord, dir: Dir): Coord =
    case dir
    of right:
      (c.x + 1, c.y)
    of down:
      (c.x, c.y + 1)
    of left:
      (c.x - 1, c.y)
    of up:
      (c.x, c.y - 1)
nbText: """
Let's use it to parse inputs:
"""
nbCode:
  let
    testGrid = parse testInput
    puzzleGrid = parse puzzleInput
  dump (testGrid.xlen, testGrid.ylen)
  dump (puzzleGrid.xlen, puzzleGrid.ylen)
  dump testGrid.sentinel
nbText: """
I am not using a `GridDiff` (I did not copy related code),
I will be using a `GridRisk` which will tell
me minimal total risk up to here and best direction I should come from.

I will also use show functions to debug.
"""
nbCode:
  type
    Risk = tuple[risk: int, dir: Dir]
    GridRisk = Grid[Risk]

  func show(g: GridInt): string =
    for c in g.coords:
      result.add $g[c]
      if c.x == g.xLen - 1:
        result.add '\n'

  func show(g: GridRisk, paddingCount=4): string =
    for c in g.coords:
      result.add align($(g[c].risk), paddingCount)
      if c.x == g.xLen - 1:
        result.add '\n'

  echo show testGrid
nbText: """
Here is the heart of the problem. Key for this is realizing
how to compute incrementally compute the risk.
"""
nbCode:
  func computeRisk(g: GridInt, gr: GridRisk, c: Coord): Risk =
    ## Computes Risk at Coord assuming Risk has been computed
    ## for cells on the left and above
    let
      riskUp = gr[c + up].risk + g[c]
      riskLeft = gr[c + left].risk + g[c]
    #debugEcho "computeRisk for c: ", c
    #debugEcho "  riskUp: ", riskUp
    #debugEcho "  riskLeft: ", riskLeft
    if riskUp <= riskLeft:
      (riskUp, up)
    else:
      (riskLeft, left)

  func computeGridRisk(g: GridInt): GridRisk =
    result.xLen = g.xLen
    result.yLen = g.ylen
    result.sentinel = (g.sentinel - 10, up) # forgot this line on first try
    # need to do - 10 to avoid overflow
    result.data = @[(0, up)]  # risk for initial position does not count
    for c in g.coords:
      if c == (0, 0): continue
      result.data.add g.computeRisk(result, c)

  func part1(gr: GridRisk): int =
    gr[(gr.xLen - 1, gr.yLen - 1)].risk
  
  let
    testGridRisk = computeGridRisk testGrid
    puzzleGridRisk = computeGridRisk puzzleGrid

  echo show testGridRisk

  dump part1 testGridRisk
  dump part1 puzzleGridRisk # 719 wrong, too high!
nbText: """
I am stuck at the moment with _a correct test result and an incorrect
puzzle result_. Not really sure how to debug.

... after looking at our discord aoc I got a useful hint (thanks @Michal58!),
the example only gives a path where the solution only goes down and to the right
and this was also my (wrong) assumption! It is indeed possible
for a minimal solution to wiggle around all directions but
my algorithm for sure is not going to find it.

So I really need to implement some [Dijkstra](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
or [A*](https://en.wikipedia.org/wiki/A*_search_algorithm) algorithm!

But first let me give a minimal example that makes it clear why I need
the better approach:
"""
nbCode:
  let
    hintInput = "19999\n19111\n11191"
    hintGrid = parse hintInput
    hintGridRisk = computeGridRisk hintGrid
  
  echo show hintGrid, "\n", show hintGridRisk



nbSave
