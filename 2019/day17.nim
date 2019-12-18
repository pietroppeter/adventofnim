import intcode, sugar

let p17 = "2019/day17.txt".readFile.parseProgram

var p = p17

discard p.run

proc toString(q: var Queue): string =
  while q.len > 0:
      result.add chr(q.pop)

let initialView = p.outQ.toString

echo initialView

type
  Vec2 = tuple[x,y: int]
  Grid = seq[seq[bool]]  # true if there is scaffold at x,y
  Robot = tuple[pos, dir: Vec2]

const
  newLine = chr(10)
  up = (0, -1)  # y axis is downward
  right = (1, 0)
  down = (1, 0)
  left = (-1, 0)

proc parseCameraView(s: string): tuple[g: Grid, r: Robot] =
  result.g.add @[]
  for c in s:
    case c:
      of '#', '^', '>', 'v', '<':
        result.g[^1].add true
        result.r.pos = (result.g[^1].len - 1, result.g.len - 1)
      of '.':
        result.g[^1].add false
      of newLine:
        result.g.add @[]
      else:
        raise ValueError.newException "cannot parse character: " & $c
    case c:
      of '^':
        result.r.dir = up
      of '>':
        result.r.dir = right
      of 'v':
        result.r.dir = down
      of '<':
        result.r.dir = left
      else:
        discard

var
  grid: Grid
  robot: Robot

(grid, robot) = initialView.parseCameraView

proc isScaffold(pos: Vec2, grid: Grid): bool =
  if pos.y >= 0 and pos.y < grid.len and pos.x >= 0 and pos.x < grid[pos.y].len:
    return grid[pos.y][pos.x]

proc `+`(v, w: Vec2): Vec2 =
  (v.x + w.x, v.y + w.y)

proc isIntersection(pos: Vec2, grid: Grid): bool =
  pos.isScaffold(grid) and (pos + up).isScaffold(grid) and (pos + right).isScaffold(grid) and (pos + down).isScaffold(grid) and (pos + left).isScaffold(grid)

proc solve1(grid: Grid): int =
  for y in 0 ..< grid.len:
    for x in 0 ..< grid[y].len:
      if (x, y).isIntersection(grid):
        result += x*y

echo "part 1: ", grid.solve1

# ......................###########........
# ......................#.........#........
# ......................#.........#........
# ......................#.........#........
# ......................#.........#........
# ......................#.........#........
# ......................#.........#####....
# ......................#.............#....
# ......................#.............#....
# ......................#.............#....
# ......#####.....#######.............#....
# ......#...#.....#...................#....
# ......#...#.....#...........#############
# ......#...#.....#...........#.......#...#
# ###########.....#...........#.......#...#
# #.....#.........#...........#.......#...#
# #.....#.......#####.........#.......#####
# #.....#.......#.#.#.........#............
# #.....#.......#.#.#.........#............
# #.....#.......#.#.#.........#............
# #############.#.#.#.........#............
# ......#.....#.#.#.#.........#............
# ......###########.###########............
# ............#.#..........................
# ..........##########^....................
# ..........#.#.#..........................
# #####.....#.#.#############..............
# #...#.....#.#.............#..............
# #...#.....#.#.............#..............
# #...#.....#.#.............#..............
# #############.............#..............
# ....#.....#...............#..............
# ....#.....#...............###########....
# ....#.....#.........................#....
# ....#.....#.........................#....
# ....#.....#.........................#....
# ....#######.........................#....
# ....................................#....
# ....................................#....
# ....................................#....
# ....................................#....
# ....................................#....
# ..............................#######....
# ..............................#..........
# ..............................#..........
# ..............................#..........
# ..............................#..........

# L10L12R6 R10L4L4L12 L10L12R6 R10L4L4L12 L10L12R6 L10R10R6L4 R10L4L4L12 L10R10R6L4 L10L12R6 L10R10R6L4
# A        B          A        B          A        C          B          C          A        C
let input2 = """
A,B,A,B,A,C,B,C,A,C
L,10,L,12,R,6
R,10,L,4,L,4,L,12
L,10,R,10,R,6,L,4
n
"""

p = p17
dump p.mem[0]
p.mem[0] = 2

proc loadInput(p: var Program, s: string) =
  for c in s:
    p.inQ.push c.ord

p.loadInput(input2)

discard p.run
echo "part 2: ", p.outQ.popLast
