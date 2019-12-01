import strutils, sets

let input = readFile("2016/day01.txt").split(", ")

type
  intVector = tuple[x: int, y: int]

proc turnRight(dir: var intVector) =
  dir = (dir.y, -dir.x)

proc turnLeft(dir: var intVector) =
  dir = (-dir.y, dir.x)

proc advance(pos: var intVector; dir: intVector, steps: int) =
  pos = (pos.x + dir.x*steps, pos.y + dir.y*steps)

proc solve(input: seq[string]): int =
  var
    pos: intVector = (0, 0)
    dir: intVector = (0, 1)
  
  for where in input:
    if where[0] == 'R':
      dir.turnRight
    else:
      dir.turnLeft
    pos.advance(dir, where[ 1 .. ^1].parseInt)
  
  return abs(pos.x) + abs(pos.y)

echo "part 1: ", input.solve

proc solve2(input: seq[string]): int =
  var
    pos: intVector = (0, 0)
    dir: intVector = (0, 1)
    seen: HashSet[intVector]

  seen.incl pos
  for where in input:
    if where[0] == 'R':
      dir.turnRight
    else:
      dir.turnLeft
    for i in 1 .. (where[ 1 .. ^1].parseInt):
      pos.advance(dir, 1)
      if pos in seen:
        return abs(pos.x) + abs(pos.y)
      seen.incl pos

echo "part 2: ", input.solve2

assert "R2, L3".split(", ").solve == 5
assert "R2, R2, R2".split(", ").solve == 2
assert "R5, L5, R5, R3".split(", ").solve == 12

assert "R8, R4, R4, R8".split(", ").solve2 == 4

