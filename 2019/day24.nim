import sets

const input = """
####.
.##..
##.#.
###..
##..#"""

type
  BugGrid = array[25, bool]

proc parse(input: string): BugGrid =
  var i = 0
  for c in input:
    if c == '#':
      result[i] = true
    elif c == '.':
      result[i] = false
    else:
      continue
    inc i

var eris = input.parse

proc `$`(grid: BugGrid): string =
  for i, bug in grid:
    if i != 0 and i mod 5 == 0:
      result &= "\n"
    if bug:
      result &= "#"
    else:
      result &= "."

echo eris

proc biodiversity(grid: BugGrid): int =
  var score = 1
  for bug in grid:
    if bug:
      result += score
    score *= 2

echo eris.biodiversity

var seen: HashSet[int]

seen.incl eris.biodiversity

proc neighbours(i: int): seq[int] =
  if i > 4:
    result.add i-5
  if (i mod 5 > 0) and i > 0:
    result.add i-1
  if (i mod 5 < 4) and i < 24:
    result.add i+1
  if i < 20:
    result.add i+5

assert 4.neighbours == @[3, 9]

proc neighbugs(grid: BugGrid, i: int): int =
  for j in i.neighbours:
    if grid[j]:
      inc result

proc evolve(grid: BugGrid): BugGrid =
  for i, bug in grid:
    if bug and grid.neighbugs(i) == 1:
      result[i] = true
    elif not bug and grid.neighbugs(i) in {1,2}:
      result[i] = true

eris = eris.evolve

seen.incl eris.biodiversity

echo eris
echo eris.biodiversity

proc solve1(grid: BugGrid): int =
  var
    seen: HashSet[int]
    grid = grid
  while true:
    grid = grid.evolve
    if grid.biodiversity in seen:
      break
    seen.incl grid.biodiversity
  echo "steps: ", seen.len
  result = grid.biodiversity

let testInput = """....#
#..#.
#..##
..#..
#...."""

var test = testInput.parse

echo "\n\ntest:"
echo test
echo test.biodiversity
test = test.evolve
echo test
echo test.biodiversity
test = test.evolve
echo test
echo test.biodiversity
test = test.evolve
echo test
echo test.biodiversity
echo "\n"

echo test.solve1
echo "\n"

echo "part 1: ", input.parse.solve1