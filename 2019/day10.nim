import math, sets, algorithm, sequtils

type
  Asteroid = tuple[x,y: int]
  AsteroidMap = HashSet[Asteroid]

proc blockers(a,b: Asteroid): HashSet[Asteroid] =
  let
    x = b.x - a.x
    y = b.y - a.y
    m = gcd(x, y)
  if a.x == b.x:
    for i in 1 ..< abs(b.y - a.y):
      if b.y > a.y:
        result.incl (a.x, a.y + i)
      else:
        result.incl (a.x, b.y + i)
    return result
  if a.y == b.y:
    for i in 1 ..< abs(b.x - a.x):
      if b.x > a.x:
        result.incl (a.x + i, a.y)
      else:
        result.incl (b.x + i, a.y)
    return result
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

proc allDetected(a: Asteroid, m: AsteroidMap): AsteroidMap =
  for b in m:
    if a.detects(b, m):
      result.incl b

proc numDetects(a: Asteroid, m: AsteroidMap): int =
  a.allDetected(m).len

#   01234
# 0 .7..7
# 1 .....
# 2 67775
# 3 ....7
# 4 ...87

assert (3, 4).numDetects(map1) == 8
assert (4, 4).numDetects(map1) == 7
assert (0, 2).numDetects(map1) == 6
echo (4, 2).blockers (4, 0)
echo (4, 2).allDetected(map1)
echo (4, 2).numDetects(map1)
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
  part1 = map0.bestLocation

echo "part 1", part1
assert part1.n == 319


#   01234567890123456
# 0 .#....###24...#..
# 1 ##...##.13#67..9#
# 2 ##...#...5.8####.
# 3 ..#.....X...###..
# 4 ..#.#.....#....##

proc greaterThan(a, b: Asteroid): bool =
  # compare with respect to origin: a > b
  # assume neither a nor b is in the origin
  doAssert not (a.x == 0 and a.y == 0) and not (b.x == 0 and b.y == 0)
  # assume a and b not on same ray (not on same line, or opposite sign)
  if not(a.y*b.x != a.x*b.y or a.x.sgn != b.x.sgn or a.y.sgn != b.y.sgn):
    raise ValueError.newException("comparing " & $a & " and " & $b)
  # upward ray > anything else
  if a.x == 0 and a.y > 0:
    return true
  elif b.x == 0 and b.y > 0:
    return false
  # right halfplane > left halfplane + downward ray
  elif a.x > 0 and b.x <= 0:
    return true
  elif b.x > 0 and a.x <= 0:
    return false
  # downward ray > left halfplane
  elif a.x == 0 and b.x < 0:
    return true
  elif b.x == 0 and a.x < 0:
    return false
  # only two cases left:
  # two asteroids both in right halfplane (x > 0): order by ratio y/x: a > b <=> ay/ax > by /bx <=> aybx > byax
  elif a.x > 0 and b.x > 0:
    return a.y*b.x > b.y*a.x
  # two asteroids in left halfplane (x < 0): reverse order by ratio y/x: a > b <=> ay/ax < by/bx <=> aybx < byax
  elif a.x < 0 and b.x < 0:
    return a.y*b.x > b.y*a.x # reversing sign gives correct answer but I am not so sure why...
  # no cases left
  else:
    debugEcho a, " ", b
    doAssert false

proc compare(a, b: Asteroid): int =
  if a.greaterThan(b):
    return -1
  else:
    return 1

assert (0, 5).greaterThan (2, 1)
assert not (-2, 0).greaterThan (0, 5)

proc `-`(a, b: Asteroid): Asteroid = (a.x - b.x, - a.y + b.y)

proc `+`(a, b: Asteroid): Asteroid = (a.x + b.x, - a.y + b.y)

proc deletionOrder(origin: Asteroid, asteroids: AsteroidMap): seq[Asteroid] =
  var
    m, d: AsteroidMap
    o, r: seq[Asteroid]
  # translate asteroids with respect to origin
  for a in asteroids:
    if a != origin:
      m.incl a - origin
  # order asteroids removing detected at every step
  while m.len > 0:
    d = (0, 0).allDetected(m)
    echo d.len
    m = m - d
    o = d.toSeq
    o.sort(compare)
    echo o[0]
    if o.len >= 200:
      echo o[199]
    r = r & o
  # reshift asteroids at the end
  for a in r:
    result.add (a + origin)

let map2 = """.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##""".parseMap
let best2 = map2.bestLocation

assert best2.a == (11, 13)
assert best2.n == 210

let
  del2 = best2.a.deletionOrder map2

#   01234567890123456789
# 0 .#..##.###...#######
# 1 ##.#########2##..##.
# 2 .#.######.##3#####.#
# 3 .###.#######.####.#.
# 4 #####.##.#.##.###.##
# 5 ..#####..#.#########
# 6 ####################
# 7 #.####....###.#.#.##
# 8 ##.#################
# 9 #####.##.###..####..
# 0 ..######..##.#######
# 1 ####.##.####...##..#
# 2 .#####..#.#1####.###
# 3 ##...#.####X#####...
# 4 #.##########.#######
# 5 .####.#.###.###.#.##
# 6 ....##.##.###..#####
# 7 .#.#.###########.###
# 8 #.#.#.#####.####.###
# 9 ###.##.####.##.#..##

echo del2[0]
assert del2[0] == (11, 12)
echo del2[1]
assert del2[1] == (12, 1)
echo del2[2]
assert del2[2] == (12, 2)
echo del2[199]


let
  deletedAsteroids = part1.a.deletionOrder map0
  a200 = deletedAsteroids[199]

echo "part 2:", a200.x*100 + a200.y
  
# 1334, too high!
# 919, too high!
# 517, correct!