import sets, strutils, std/enumerate, strformat
import sugar
let example = """.#.
..#
###"""
let input = """##..####
.###....
#.###.##
#....#..
...#..#.
#.#...##
..#.#.#.
.##...#."""

type
  Vec4 = tuple[x,y,z,q: int] # q instead of w since I use w for vector
  Active = HashSet[Vec4]
  Mat4 = tuple[a, b, c, d: Vec4]

proc parse(text: string): Active =
  for y, line in enumerate(text.splitLines):  # why does this need enumerate?
    for x, c in line:
      if c == '#':
        result.incl (x, y, 0, 0)

func `+`(v, w: Vec4): Vec4 = (v.x + w.x, v.y + w.y, v.z + w.z, v.q+w.q)
func `*`(v, w: Vec4): int = (v.x * w.x + v.y * w.y + v.z * w.z + v.q * w.q)
func `*`(m: Mat4, v: Vec4): Vec4 = (m.a*v, m.b*v, m.c*v, m.d*v)

iterator quadruple(a: array[3, int]): Vec4 =
  for x in a:
    for y in a:
      for z in a:
        for q in a:
          yield (x, y, z, q)

iterator neighbours(v: Vec4): Vec4 =
  let m: Mat4 = ((1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1))
  for u in quadruple([-1, 0, 1]):
    if u == (0, 0, 0, 0):
      continue
    yield v + m*u

func bbox(a: Active): (int, int, int, int, int, int, int, int) =
  var xmin, xmax, ymin, ymax, zmin, zmax, qmin, qmax: int
  (xmin, ymin, zmin, qmin) = (int.high, int.high, int.high, int.high)
  (xmax, ymax, zmax, qmax) = (-int.high, -int.high, -int.high, -int.high)
  for v in a:
    if v.x < xmin:
      xmin = v.x
    if v.x > xmax:
      xmax = v.x
    if v.y < ymin:
      ymin = v.y
    if v.y > ymax:
      ymax = v.y
    if v.z < zmin:
      zmin = v.z
    if v.z > zmax:
      zmax = v.z
    if v.q < qmin:
      qmin = v.q
    if v.q > qmax:
      qmax = v.q
  (xmin, xmax, ymin, ymax, zmin, zmax, qmin, qmax)

proc cycle(a: Active): Active =
  var b = a
  let
    (xmin, xmax, ymin, ymax, zmin, zmax, qmin, qmax) = bbox a
  var
    cnt: int
    w: Vec4
  for x in (xmin - 1)..(xmax + 1):
    for y in (ymin - 1)..(ymax + 1):
      for z in (zmin - 1)..(zmax + 1):
        for q in (qmin - 1)..(qmax + 1):
          cnt = 0
          w = (x, y, z, q)
          for v in neighbours(w):
            if v in a:
              inc cnt
          if w in a and cnt in [2, 3]:
            b.incl w
          else:
            b.excl w
          if w notin a and cnt == 3:
            b.incl w
  b

var a: Active
template reset =
  clear a

func viz(a: Active): string =
  let (xmin, xmax, ymin, ymax, zmin, zmax, qmin, qmax) = bbox a
  for q in qmin..qmax:
    for z in zmin..zmax:
      result.add &"q = {q}, z= {z}, y in {ymin..ymax}, x in {xmin}..{xmax}\n"
      for y in ymin..ymax:
        for x in xmin..xmax:
          if (x, y, z, q) in a:
            result.add "#"
          else:
            result.add "."
        result.add "\n"
      result.add "\n"

a = parse example
echo a
echo bbox(a)
echo "\n---\n"
echo viz(a)
echo "\n---\n"

for i in 1..3:
  a = cycle a
  echo viz(a)
  echo "\n---\n"

for i in 1..3:
  a = cycle a

echo a.len  # 

a = parse input
for i in 1..6:
  a = cycle a
echo a.len
