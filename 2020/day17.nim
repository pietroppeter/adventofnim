import nimib, animu, nimoji

nbInit
nbText: """## 2020, Day 17: Conway Cubes :black_square_button: :white_square_button:

Today is about implementing game of life in 3 or 4 dimensions.
The usual thing to be careful about is to make a copy of the data structure you use to track active cells.

My implementation is really basic and part2 is just a modified version of part1.
The only highlight is a `Mat3` type and a `triple` iterator to implement `neighbours` iterator.

I did suffer a bit because it took a moment to find a bug
(I was forgetting to remove cubes that become inactive, I though I was starting from an empty buffer but I was not).
""".emojize

nbText: "some imports and my inputs:"
nbCode:
  import sets, strutils, std/enumerate, strformat

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

nbText: "Usual parsing:"
nbCode:
  type
    Vec3 = tuple[x,y,z: int]
    Active = HashSet[Vec3]

  proc parse(text: string): Active =
    for y, line in enumerate(text.splitLines):  ## why does this need enumerate?
      for x, c in line:
        if c == '#':
          result.incl (x, y, 0)

  echo parse example

nbText: "yes, I should have written a template for bbox, but I was lazy. Anyway I reproduced the vizualization:"
nbCode:
  func bbox(a: Active): (int, int, int, int, int, int) =
    var xmin, xmax, ymin, ymax, zmin, zmax: int
    (xmin, ymin, zmin) = (int.high, int.high, int.high)
    (xmax, ymax, zmax) = (-int.high, -int.high, -int.high)
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
    (xmin, xmax, ymin, ymax, zmin, zmax)


  func viz(a: Active): string =
    let (xmin, xmax, ymin, ymax, zmin, zmax) = bbox a
    for z in zmin..zmax:
      result.add &"z= {z}, y in {ymin..ymax}, x in {xmin}..{xmax}\n"
      for y in ymin..ymax:
        for x in xmin..xmax:
          if (x, y, z) in a:
            result.add "#"
          else:
            result.add "."
        result.add "\n"
      result.add "\n"

  var a = parse example
  echo viz(a)

nbText: "Here is the only bit of creativity I had for today: a `Mat3` type and two iterators that help me generate the neighbours."
nbCode:
  type
    Mat3 = tuple[a, b, c: Vec3]

  func `+`(v, w: Vec3): Vec3 = (v.x + w.x, v.y + w.y, v.z + w.z)
  func `*`(v, w: Vec3): int = (v.x * w.x + v.y * w.y + v.z * w.z)
  func `*`(m: Mat3, v: Vec3): Vec3 = (m.a*v, m.b*v, m.c*v)

  iterator triple(a: array[3, int]): Vec3 =
    for x in a:
      for y in a:
        for z in a:
          yield (x, y, z)

  iterator neighbours(v: Vec3): Vec3 =
    let m: Mat3 = ((1, 0, 0), (0, 1, 0), (0, 0, 1))
    for u in triple([-1, 0, 1]):
      if u == (0, 0, 0):
        continue
      yield v + m*u

  for v in neighbours((0, 0, 0)):
    echo v

nbText: "This is the key function"
nbCode:
  proc cycle(a: var Active) =
    var b = a
    let
      (xmin, xmax, ymin, ymax, zmin, zmax) = bbox a
    var
      cnt: int
      w: Vec3
    for x in (xmin - 1)..(xmax + 1):
      for y in (ymin - 1)..(ymax + 1):
        for z in (zmin - 1)..(zmax + 1):
          cnt = 0
          w = (x, y, z)
          for v in neighbours(w):
            if v in a:
              inc cnt
          if w in a and cnt in [2, 3]:
            b.incl w
          else: ## I was forgetting this branch
            b.excl w
          if w notin a and cnt == 3:
            b.incl w
    a = b

nbText: "Reproducing first 3 loops for the example:"
nbCode:
  for i in 1..3:
    cycle a
    echo viz(a)
    echo "---\n"
nbText: "solving the example"
nbCode:
  for i in 1..3:
    cycle a

  echo a.len  ## 112

nbText: "Finally, let's go for the input:"
nbCode:
  a = parse input
  for i in 1..6:
    cycle a
  echo "part 1:", a.len

gotTheStar

nbText: """
Part 2 is a straightforward change from part 1.
You can look it up in the repo (I named for fourth dimension `q` because I wanted to keep using `w` for vector).
"""

gotTheStar

nbSave