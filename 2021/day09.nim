import animu

type
  Coord = tuple[x, y: int]
  Grid[T] = object
    data: seq[T]
    yLen, xLen: int
    sentinel: T  # value for outside the grid
  GridInt = Grid[int]
  Dir = enum
    right, down, left, up
  Diff = array[Dir, int]
  GridDiff = Grid[Diff]

func toIndex[T](g: Grid[T], c: Coord): int =
  if c.x < 0 or c.x >= g.xLen or c.y < 0 or c.y >= g.yLen:
    -1
  else:
    c.y*g.yLen + c.x

func `[]`[T](g: Grid[T], c: Coord): T =
  let i = g.toIndex(c)
  if i < 0:
    g.sentinel
  else:
    g.data[i]

func isLowPoint(gd: GridDiff, c: Coord): bool =
  for dir in Dir:
    if gd[c][dir] <= 0:
      return false
  true

func findAllLowPoints(gd: GridDiff): seq[Coord] =
  for y in 0 ..< gd.yLen:
    for x in 0 ..< gd.yLen:
      if gd.isLowPoint (x, y):
        result.add (x, y)

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

func part1(g: GridInt, gd: GridDiff): int =
  let lowPoints = gd.findAlllowPoints
  for lowPoint in lowPoints:
    result += g[lowPoint]

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

func computeDiff(g: GridInt): GridDiff =
  result.xLen = g.xLen
  result.yLen = g.ylen
  result.data = newSeqWith(len=g.data.len): [0, 0, 0, 0]
  # sentinel not set (do not need it for the moment)
  for c in g.coords:
    for dir in Dir:
      let i = g.toIndex(c)
      result.data[i][dir] = g[c + dir] - g[c]

let
  testInput = """
2199943210
3987894921
9856789892
8767896789
9899965678"""
  testGrid = parse testInput
  puzzleInput = readFile("2021/input09.txt")
  puzzleGrid = parse puzzleInput
  testGridDiff = testGrid.computeDiff
  puzzleGridDiff = puzzleGrid.computeDiff

dump part1(testGrid, testGridDiff)