import nimib, animu, nimoji

nbInit
nbText: """## 2020, Day 12: Rain risk :umbrella: :ferry:

Another classic AOC in moving according to directions.
Nice change of specs from part1 to part2,
but I just added a proc overload and I was good to go
(although my "legacy" Enum names do not really shine in part2).
I did implement the bare minimum (while being my usual verbose,
I am sure other people have much more synthetic solutions)
and got away with it very quick.

As for imports today is just one. Yep `parseEnum` and `parseInt`
are in `strutils` and not in `parseutils`.
`parseutils` contains parse functions that return an `int`.
""".emojize

nbCode:
  import strutils

nbText: "All my types below. Using Vec2 both for pos and dir although I could go fancy and use a distinct UnitVec2"
nbCode:
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

nbText: "template will be useful between example and input and also for part2"
nbCode:
  var ship: Ship
  template resetShip =
    ship.pos = (0, 0)
    ship.dir = (1, 0)
  resetShip

nbText: "no need to come up with fancy names. `parse` is fine."
nbCode:
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

nbText: "my set of functions for Vec2, I will support only left rotation..."
nbCode:
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
    ## I could do it for a Vec2 but I will use it only for the ship, so...
    abs(ship.pos.x) + abs(ship.pos.y)

nbText: "heart of the solution is this, rather straightforward now:"
nbCode:
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

nbText: "Let's move according to example instructions, printing out in case I need to debug"
nbCode:
  echo ship
  for instr in parse(example):
    ship.move instr
    echo "-> ", instr
    echo ship

  echo manhattan ship ## 25

nbText: "all good, now the input!"
nbCode:
  let input = "2020/input12.txt".readFile

  resetShip
  for instr in parse(input):
    ship.move instr

  echo manhattan ship  ## 1601

gotTheStar

nbText: "### Part2\nI just add a waypoint var and add overload for `move`:"
nbCode:
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

gotTheStar

nbText: """
I was a bit nervous about this day 12 since last two years day 12 is where
I started to lag behind.
Instead it was a piece of cake :cake: and my fastest :zap: submission with no bugs :beetle:.

I probably am becoming a little better at this, but I do have a feeling like
this year is slightly easier, maybe Eric is cutting us some slack because of, you know, 2020...

Of course I will regret just saying this tomorrow and the next days... :scream:
""".emojize
# the only error I got today was when compiling after the nimib version:
# the usual error on parsing the example (forgot to dedent the multiline)
nbSave
# I probably should add to nimib something like the following:
#[
nbSaveCode # saves a nim file with just code
nbAddCodeSource # adds to context the content of code blocks (it should be then made available from html for easier extraction)
# in particular all code snippets should have easy pasting of code and you should also have a complete pasting for the whole code snippets
]#