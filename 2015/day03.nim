import tables

let input = "2015/day03.txt".readFile

type Vec2 = tuple[x, y: int]

var
  pos: Vec2
  countPresents = initCountTable[Vec2]()

countPresents.inc(pos)

for c in input:
  case c:
    of '^':
      pos.y += 1
    of '>':
      pos.x += 1
    of 'v':
      pos.y -= 1
    of '<':
      pos.x -= 1
    else:
      raise newException(ValueError, "damn elf!")
  countPresents.inc(pos)

# echo countPresents

echo "part 1: ", countPresents.len

var
  pos1, pos2: Vec2
  is2: bool

countPresents.clear
countPresents.inc(pos1)
countPresents.inc(pos2)

for c in input:
  if is2:
    pos = pos2
  else:
    pos = pos1
  case c:
    of '^':
      pos.y += 1
    of '>':
      pos.x += 1
    of 'v':
      pos.y -= 1
    of '<':
      pos.x -= 1
    else:
      raise newException(ValueError, "damn elf!")
  countPresents.inc(pos)
  if is2:
    pos2 = pos
  else:
    pos1 = pos
  is2 = not is2

echo "part 2: ", countPresents.len
