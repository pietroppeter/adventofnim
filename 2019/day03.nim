import strutils, sets, sequtils, strformat

let input = readFile("2019/day03.txt").splitLines.mapIt(it.split(","))

echo input.len, " ", input[0].len, " ", input[1].len

type
  Vector = tuple[x: int, y: int]
  Direction = enum
    right, up, left, down
  Instruction = seq[tuple[dir: Direction, len: int]]
  HorizontalLine = tuple
    y, x1, x2: int
  VerticalLine = tuple
    x, y1, y2: int
  Wire = tuple
    hLines: seq[HorizontalLine]
    vLines: seq[VerticalLine]

let
  example1 = "R8,U5,L5,D3".split(",")
  example2 = "U7,R6,D4,L4".split(",")

proc parseInstruction(input: seq[string]): Instruction =
  for s in input:
    case s[0]:
      of 'R':
        result.add (right, parseInt s[1 .. ^1])
      of 'U':
        result.add (up, parseInt s[1 .. ^1])
      of 'L':
        result.add (left, parseInt s[1 .. ^1])
      of 'D':
        result.add (down, parseInt s[1 .. ^1])
      else:
        raise newException(ValueError, "invalid instruction: " & s)

let
  inst1 = parseInstruction example1
  inst2 = parseInstruction example2

proc initWire(instruction: Instruction): Wire =
  var
    pos:Vector = (x: 0, y: 0)
  for inst in instruction:
    case inst.dir:
      of right:
        result.hLines.add (pos.y, pos.x, pos.x + inst.len)
        pos.x += inst.len
      of up:
        result.vLines.add (pos.x, pos.y, pos.y + inst.len)
        pos.y += inst.len
      of left:
        result.hLines.add (pos.y, pos.x, pos.x - inst.len)
        pos.x -= inst.len
      of down:
        result.vLines.add (pos.x, pos.y, pos.y - inst.len)
        pos.y -= inst.len

let
  wire1 = initWire inst1
  wire2 = initWire inst2

echo wire1
echo wire2

proc cross(hLine: HorizontalLine, vLine: VerticalLine): tuple[yes: bool, pos: Vector] =
  if hLine.y > min(vLine.y1, vLine.y2) and hLine.y < max(vline.y1, vLine.y2) and
     vLine.x > min(hLine.x1, hLine.x2) and vLine.x < max(hLine.x1, hLine.x2):
    result = (true, (vLine.x, hLine.y))

echo wire1.hLines[1].cross wire2.vLines[1]
echo wire2.hLines[1], wire1.vLines[1], wire2.hLines[1].cross wire1.vLines[1]

proc cross(wireA, wireB: Wire): seq[Vector] =
  for hLine in wireA.hLines:
    for vLine in wireB.vLines:
      let c = hLine.cross vLine
      if c.yes:
        result.add c.pos
  for hLine in wireB.hLines:
    for vLine in wireA.vLines:
      let c = hLine.cross vLine
      if c.yes:
        result.add c.pos

let crossings12 = wire1.cross wire2

proc minManhattan(points: seq[Vector]): int =
  result = int.high
  for p in points:
    let d = abs(p.x) + abs(p.y)
    if d < result:
      result = d

echo minManhattan crossings12

let
  wireA = initWire parseInstruction input[0]
  wireB = initWire parseInstruction input[1]
  crossingsAB = wireA.cross wireB

echo "part 1: ", minManhattan crossingsAB

proc startH(w: Wire): bool =
  if w.hLines[0].y == 0 and w.hLines[0].x1 == 0:
    return true

proc cross(p: Vector, l: HorizontalLine): tuple[yes: bool, dist: int] =
  if p.y == l.y and p.x > l.x1 and p.x < l.x2:
    return (true, abs(p.x - l.x1))
  elif p.y == l.y and p.x > l.x2 and p.x < l.x1:
    return (true, abs(p.x - l.x1))
  else:
    return (false, abs(l.x2 - l.x1))

proc cross(p: Vector, l: VerticalLine): tuple[yes: bool, dist: int] =
  if p.x == l.x and p.y > l.y1 and p.y < l.y2:
    return (true, abs(p.y - l.y1))
  elif p.x == l.x and p.y > l.y2 and p.y < l.y1:
    return (true, abs(p.y - l.y1))
  else:
    return (false, abs(l.y2 - l.y1))
    
proc signal(w: Wire, p: Vector): int =
  let
    hLen = w.hLines.len
    vLen = w.vLines.len
  var
    hNow = w.startH
  var h, v = 0
  # echo fmt"p: {p}, w: {w}"
  while h < hLen or v < vLen:
    if hNow:
      let c = p.cross w.hLines[h]
      result += c.dist
      # echo fmt"  l: {w.hLines[h]} c: {c}"
      if c.yes:
        return result
      inc h
      hNow = not hNow
    else:
      let c = p.cross w.vLines[v]
      result += c.dist
      # echo fmt"  l: {w.vLines[v]} c: {c}"
      if c.yes:
        return result
      inc v
      hNow = not hNow

proc minSignal(points: seq[Vector], wireA, wireB: Wire): int =
  result = int.high
  for p in points:
    let d = wireA.signal(p) + wireB.signal(p)
    if d < result:
      result = d

echo crossings12.minSignal(wire1, wire2)
echo "part 2: ", crossingsAB.minSignal(wireA, wireB)