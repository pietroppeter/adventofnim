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

func isLowPoint(gd: GridDiff, c: Coord): bool =
  for dir in Dir:
    if gd[c][dir] <= 0:
      return false
  true

func findAllLowPoints(gd: GridDiff): seq[Coord] =
  for y in 0 ..< gd.yLen:
    for x in 0 ..< gd.xLen:
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
    result += g[lowPoint] + 1

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
  result.data = @[[0, 0, 0, 0]]
  for i in 1 ..< g.data.len:
    result.data.add [0, 0, 0, 0]
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
  testGridDiff = testGrid.computeDiff
  puzzleInput = readFile("2021/input09.txt")
  puzzleGrid = parse puzzleInput
  puzzleGridDiff = puzzleGrid.computeDiff

dump part1(testGrid, testGridDiff)
dump part1(puzzleGrid, puzzleGridDiff)

# part 2
import sets, deques

func findBasin(g: Grid, c: Coord): HashSet[Coord] =
  result.incl c
  var
    queue = [c].toDeque
    d, e: Coord
  while queue.len > 0:
    d = queue.popFirst
    for dir in Dir:
      e = d + dir
      if not e.isOutside(g) and e not_in result and g[e] < 9:
        result.incl e
        queue.addLast e
      
func findAllBasins(g: Grid, gd: GridDiff): seq[HashSet[Coord]] =
  let lowPoints = gd.findAllLowPoints
  for lowPoint in lowPoints:
    result.add g.findBasin lowPoint

func getTop(s: seq[int], n: int): seq[int] =
  assert s.len >= n
  s.sorted[^n .. ^1]

func part2(g: Grid, gd: GridDiff): int =
  findAllBasins(g, gd).mapIt(it.len).getTop(3).prod

dump part2(testGrid, testGridDiff)
dump part2(puzzleGrid, puzzleGridDiff)
