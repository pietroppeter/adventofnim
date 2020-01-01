import intcode, tables, sugar

let p19 = "2019/day19.txt".readFile.parseProgram

type
  Vec2 = tuple[x,y: int]
  Grid = Table[Vec2, bool]

var
  grid: Grid
  count = 0

proc isBeam(x, y: int): bool =
  var p = p19
  p.inQ.push x
  p.inQ.push y
  discard p.run
  if p.outQ.pop == 1:
    return true


for y in 0 .. 49:
  for x in 0 .. 49:
    grid[(x, y)] = isBeam(x, y)
    if grid[(x, y)]:
      inc count

echo "part 1: ", count

proc print(g: Grid, ymin = 0, ymax = 49, xmin = 0, xmax = 49): string =
  for y in ymin .. ymax:
    for x in xmin .. xmax:
      if (x, y) notin g:
        result &= " "
      elif g[(x, y)]:
        result &= "#"
      else:
        result &= "."
    result &= "\n"

echo grid.print

const ymax = 10_000

type
  CheckResult = tuple[x,y,l: int]

proc checkSquare(x, y: int): CheckResult =
  var
    x = x
    y = y
    l = 0
  while not isBeam(x, y):
    inc y
    if y > ymax:
      raise ValueError.newException "reached ymax"
  result.y = y
  while isBeam(x, y):
    inc y
    dec x
    inc l
  result.x = x + 1
  result.l = l

echo checkSquare(12, 0)

proc findSquare(size: int, x=5, y=0): Vec2 =
  var
    check: CheckResult
    x = x
    y = y
  while true:
    check = checkSquare(x, y)
    if check.l >= size:
      return (check.x, check.y)
    y = check.y
    x = check.x + check.l

echo findSquare(2)

let part2 = findSquare(100, x= 50, y = 30)

echo part2
echo "part 2: ", part2.x*10_000 + part2.y
