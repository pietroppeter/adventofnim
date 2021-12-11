import animu

type
  Octopus = object
    level: int
    flashed: bool
  Cave = object
    octos: seq[Octopus]
    xLen, yLen: int
    queue: seq[int]

func neighbours(c: Cave, i: int): seq[int] =
  template x(i: int): int = i mod c.xLen
  template y(i: int): int = i div c.xLen
  for j in [-1, 0, 1]:
    for k in [-c.xLen, 0, c.xLen]:
      if (j == 0 and k == 0) or
         (i.x == 0 and j == -1) or
         (i.x == (c.xLen - 1) and j == 1) or
         (i.y == 0 and k < 0) or
         (i.y == (c.yLen - 1) and k > 0):
        continue
      result.add i + j + k

func tick(c: var Cave, i: int): int =
  if c.octos[i].flashed:
    return
  inc c.octos[i].level
  if c.octos[i].level > 9:
    c.octos[i].flashed = true
    c.octos[i].level = 0
    c.queue.add c.neighbours i
    result = 1

func tick(c: var Cave): int =
  for i in 0 .. c.octos.high:
    c.octos[i].flashed = false
    result += c.tick i
  while c.queue.len > 0:
    result += c.tick c.queue.pop

func part1(c: Cave): int =
  var c = c
  for i in 1 .. 100:
    result += tick c

func parseInt(c: char): int =
  result = ord(c) - ord('0')
  assert result >= 0 and result <= 9

func parse(text: string): Cave =
  for line in text.splitLines:
    inc result.yLen
    result.xLen = line.len
    for c in line:
      result.octos.add Octopus(level: parseInt(c))

let
  puzzleInput = """
4871252763
8533428173
7182186813
2128441541
3722272272
8751683443
3135571153
5816321572
2651347271
7788154252"""
  puzzleCave = parse puzzleInput
  testInput = """
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"""
  testCave = parse testInput

dump part1 testCave # 2051 too high
dump part1 puzzleCave # 2051 too high

func `$`(c: Cave): string =
  for i, o in c.octos:
    result.add $c.octos[i].level
    if (i + 1) mod c.xLen == 0:
      result.add '\n'

#[ weird bug, if I do this then testCave is zeroed out!
var c = testCave
echo c
echo "flashes: ", tick c
echo "after 1 step:\n", c
]#

func part2(c: Cave): int =
  var
    c = c
    n: int
  for i in 1 .. 2000:
    n = tick c
    #debugEcho "i: ", i, ";n: ", n
    if n == c.xLen*c.yLen:
      return i
dump part2 testCave 
dump part2 puzzleCave
dump (testCave.xlen, testCave.yLen)
dump (puzzleCave.xlen, puzzleCave.yLen)
dump testCave
