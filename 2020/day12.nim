import strutils, parseutils

type
  Vec2 = tuple[x, y: int]
  Ship = object
    pos: Vec2
    dir: Vec2 ## it could be a distinct type (UnitVec2)
  InstructionKind = enum
    goNorth = "N", goEast = "E", goSouth = "S", goWest = "W",
    goForward = "F", rotLeft = "L", rotRight = "R"
    ## here I am breaking from naming convention of enums
  Instruction = object
    kind: InstructionKind
    val: int

var ship: Ship
template resetShip =
  ship.pos = (0, 0)
  ship.dir = (1, 0)
resetShip

proc parse(text: string): seq[Instruction] =
  var instr: Instruction
  for line in text.splitLines:
    instr.kind = parseEnum[InstructionKind](line[0..0])
    instr.val = parseInt(line[1 .. ^1])
    result.add instr

let example = """F10
N3
F7
R90
F11"""

echo parse example

func `+`(v,w: Vec2): Vec2 = (v.x + w.x, v.y + w.y)
func `*`(s: int, v: Vec2): Vec2 = (s*v.x, s*v.y)
func rotL(v: Vec2, deg: int): Vec2 =
  case deg:
    of 180, -180:
      (-v.x, -v.y)
    of 90, -270:
      (-v.y, v.x) ## (1, 0) -> (0, 1) -> (-1, 0)
    of -90, 270:
      (v.y, -v.x) ## (1, 0) -> (0, -1) -> (-1, 0)
    else:
      debugEcho "ERROR not supported"
      (0, 0)
template `+=`(a, b: untyped) =
  a = a + b

func manhattan(ship: Ship): int =
  abs(ship.pos.x) + abs(ship.pos.y)

proc move(ship: var Ship, instr: Instruction) =
  case instr.kind:
    of goForward:
      ship.pos += instr.val*ship.dir
    of goNorth:
      ship.pos += instr.val*(0, 1)
    of goEast:
      ship.pos += instr.val*(1, 0)
    of goSouth:
      ship.pos += instr.val*(0, -1)
    of goWest:
      ship.pos += instr.val*(-1, 0)
    of rotLeft:
      ship.dir = ship.dir.rotL(instr.val)
    of rotRight:
      ship.dir = ship.dir.rotL(-instr.val)

echo ship
for instr in parse(example):
  ship.move instr
  echo "-> ", instr
  echo ship

echo manhattan ship

let input = "2020/input12.txt".readFile

resetShip
for instr in parse(input):
  ship.move instr

echo manhattan ship

var waypoint: Vec2
template resetWaypoint =
  waypoint = (10, 1)
resetWaypoint

proc move(ship: var Ship, waypoint: var Vec2, instr: Instruction) =
  case instr.kind:
    of goForward:
      ship.pos += instr.val*waypoint
    of goNorth:
      waypoint += instr.val*(0, 1)
    of goEast:
      waypoint += instr.val*(1, 0)
    of goSouth:
      waypoint += instr.val*(0, -1)
    of goWest:
      waypoint += instr.val*(-1, 0)
    of rotLeft:
      waypoint = waypoint.rotL(instr.val)
    of rotRight:
      waypoint = waypoint.rotL(-instr.val)

resetShip
echo ship
for instr in parse(example):
  ship.move(waypoint, instr)
  echo "W: ", waypoint
  echo "-> ", instr
  echo ship

echo manhattan ship

resetShip
resetWaypoint
for instr in parse(input):
  ship.move(waypoint, instr)

echo manhattan ship
