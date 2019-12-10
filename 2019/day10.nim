import math, sets

type
  Asteroid = tuple[x,y: int]
  AsteroidMap = HashSet[Asteroid]

proc blockers(a,b: Asteroid): HashSet[Asteroid] =
  let
    x = b.x - a.x
    y = b.y - a.y
    m = gcd(x, y)
  for i in 1 ..< m:
    result.incl (a.x + i*(x div m), a.y + i*(y div m))

#   0123456789
# 0 #.........
# 1 ...A......
# 2 ...B..a...
# 3 .EDCG....a
# 4 ..F.c.b...
# 5 .....c....
# 6 ..efd.c.gb
# 7 .......c..
# 8 ....f...c.
# 9 ...e..d..c

echo (0, 0).blockers (6, 2)  # {(x: 3, y: 1)}
echo (0, 0).blockers (9, 3)
echo (0, 0).blockers (9, 9)
echo (3, 1).blockers (9, 3)
echo (0, 0).blockers (5, 0)
assert ((0, 0).blockers (9, 9)) == ((9, 9).blockers (0, 0))  # blockers is symmetric (although its implementation isn't)
echo (3, 4).blockers (1, 0)

proc parseMap(text: string): AsteroidMap =
  var x,y: int
  for c in text:
    case c:
      of '.':
        inc x
      of '#':
        result.incl (x,y)
        inc x
      else:  # assume '\n'
        inc y
        x = 0

let map1text = """.#..#
.....
#####
....#
...##"""
let map1 = map1text.parseMap

proc detects(a, b: Asteroid, m: AsteroidMap): bool =
  if a == b: return false
  for c in a.blockers b:
    if c in m:
      return false
  return true

#   01234
# 0 .#..#
# 1 .....
# 2 #####
# 3 ....#
# 4 ...##

assert (0, 2).detects((1, 2), map1)
assert not (0, 2).detects((3, 2), map1)
assert (3, 4).detects((4, 0), map1)
assert not (3, 4).detects((1, 0), map1)

proc numDetects(a: Asteroid, m: AsteroidMap): int =
  for b in m:
    if a.detects(b, m):
      inc result

#   01234
# 0 .7..7
# 1 .....
# 2 67775
# 3 ....7
# 4 ...87

assert (3, 4).numDetects(map1) == 8
assert (4, 4).numDetects(map1) == 7
assert (0, 2).numDetects(map1) == 6
assert (4, 2).numDetects(map1) == 5

proc bestLocation(m: AsteroidMap): tuple[a: Asteroid, n: int] =
  var n: int
  for a in m:
    n = a.numDetects m
    if n > result.n:
      result.a = a
      result.n = n

echo map1.bestLocation

let
  input = "2019/day10.txt".readFile
  map0 = input.parseMap

echo "part 1", map0.bestLocation