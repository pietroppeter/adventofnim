import nimib, animu

nbInit

nbText: "# --- Example ---"

nbCode:
  let example = """
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#""".strip
  echo example

nbCode:
  type
    StrideMap = object
      data: seq[char]
      stride: int
      height: int
    Shape = tuple[stride, height: int]

  proc parse(text: string): StrideMap =
    for line in text.splitLines:
      inc result.height
      result.data.add toSeq(line)
      if result.stride > 0 and line.len != result.stride:
        echo "ParseError: line does not matches stride"
      result.stride = line.len
  
  let map0 = parse example
  func shape(m: StrideMap): Shape = (m.stride, m.height)
  
  echo "shape:", map0.shape

nbText: "let's add coordinates:"

nbCode:
  type
    Point = tuple[x, y: int]
  proc index(p: Point, m: StrideMap): int =
    var x = p.x mod m.stride
    if p.y >= m.height: echo "ERROR: point too low!"
    x + p.y*m.stride

  proc `[]`(m: StrideMap, p: Point): char =
    m.data[p.index m]

  for p in [(3, 1), (6, 2)]:
    echo p
    echo "index: ", p.index(map0)
    echo "on map: ", map0[p]

nbCode:
  type
    Slope = tuple[dx, dy: int]
    Path = seq[Point]
    Ride = tuple[path: Path, ntrees: int]
  
  proc `+`(p: Point, s: Slope): Point =
    result.x = p.x + s.dx
    result.y = p.y + s.dy

  proc ride(m: StrideMap, s: Slope): Ride =
    var p: Point
    let ySteps = m.height div s.dy  # this part I forgot on first round
    for i in 1 ..< ySteps:
      p = p + s
      result.path.add p
      if m[p] == '#':
        inc result.ntrees
  
  let ride0 = ride(map0, (3, 1))
  echo "ntrees: ", ride0.ntrees  # expect 7

nbText: """## --- Part 1 ---
now we are equipped to solve part1:"""

nbCode:
  let
    input = "2020/input03.txt".readFile
    map1 = parse input
    ride1 = ride(map1, (3, 1))
  echo "part1: ", ride1.ntrees
    
gotTheStar

nbText: """## --- Part 2 ---
easy second part"""

template nbNone(body: untyped) = body

nbNone:
  let slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
  var
    ntrees2: int
    part2 = 1
  # Example first, I expect: 2, 7, 3, 4, and 2. Total: 336
  for slope in slopes:
    echo slope
    ntrees2 = ride(map0, slope).ntrees
    echo ntrees2
    part2 *= ntrees2
  echo "part2(example): ", part2

nbText: "tricky last slope made me discover my implementation bug!"
nbText: "now onto part2 on my puzzle input"

nbCode:
  part2 = 1
  for slope in slopes:
    part2 *= ride(map1, slope).ntrees
  echo "part2: ", part2

gotTheStar

nbText: "# Visualizations"
nbText: """I want to try to take advantage of the fact that I output html.

I will reproduce the explantory design showing the ride through the example.
"""

nbCode:
  proc show(m: StrideMap, r: Ride, repeat=6) =
    var line = ""
    var
      i = 0
      j = 0
      p: Point = r.path[j]
      c: char
    for y in 0 ..< m.height:
      for x in 0 ..< m.stride:
        line.add m.data[i]
        inc i

      line = line.repeat(repeat)
      if y == p.y:
        c = if m[p] == '.': 'O' else: 'X'
        line = line[0 ..< p.x] & "<em>" & $c & "</em>" & line[p.x + 1 .. ^1]
        inc j
        if j < r.path.len:
          p = r.path[j]
      echo line
      line = ""
  show(map0, ride0)
  echo map1.shape
# hey: nbBlock is not available! I need to inject it!!
# nbBlock.output = "<span style=\"\">" & nbBlock.output & "</span>"

nbSave