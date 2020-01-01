import intcode, tables

let p11 = "2019/day11.txt".readFile.parseProgram

var p = p11

type
  Vec2 = tuple[x,y: int]
  Hull = Table[Vec2, bool]  # true -> white paint
  Robot = tuple[d: Vec2; x, y: int]

proc isWhite(h: Hull; x, y: int): bool = (x, y) in h and h[(x, y)]

proc turn(r: var Robot, turnRight: bool) =
  if turnRight:
    (r.d.x, r.d.y) = (r.d.y, -r.d.x)  # (0, 1) -> (1, 0) and (1, 0) -> (0, -1)
  else:
    (r.d.x, r.d.y) = (-r.d.y, r.d.x)  # (0, 1) -> (-1, 0) and (1, 0) -> (0, 1)

proc advance(r: var Robot) =
  r.x += r.d.x
  r.y += r.d.y 

proc step(r: var Robot, p: var Program, h: var Hull) =
  if h.isWhite(r.x, r.y):
    p.inQ.push 1
  else:
    p.inQ.push 0
  discard p.run
  let
    colorWhite = (p.outQ.pop == 1)
    turnRight = (p.outQ.pop == 1)
  h[(r.x, r.y)] = colorWhite
  r.turn turnRight
  r.advance

proc show(h: Hull): string =
  var xmin, xmax, ymin, ymax = 0
  for k in h.keys:
    if k.x < xmin:
      xmin = k.x
    if k.x > xmax:
      xmax = k.x
    if k.y < ymin:
      ymin = k.y
    if k.y > ymax:
      ymax = k.y
  for y in countdown(ymax, ymin):
    for x in xmin .. xmax:
      if h.isWhite(x, y):
        result &= "#"
      else:
        result &= "."
    result &= "\n"
  
var
  r = ((0, 1), 0, 0).Robot
  h: Hull

while not p.isHalted:
  r.step p, h

echo "part 1: ", h.len

echo h.show

# re intialize for part 2
echo "\npart 2:"
p = p11
r = ((0, 1), 0, 0).Robot
h.clear
h[(0, 0)] = true

while not p.isHalted:
  r.step p, h

echo h.show
# EGHKGJER