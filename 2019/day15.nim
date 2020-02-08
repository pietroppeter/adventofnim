include prelude
import intcode

let p15 = "2019/day15.txt".readFile.parseProgram

var p = p15

template region(header, body: untyped) {.dirty.} = body

region(types):
  type
    Direction = enum
      dirNorth = 1, dirSouth, dirWest, dirEast
    Vec2 = tuple[x,y: int]
    Legend = enum 
      wall, space, oxygen
    LabyrinthMap = Table[Vec2, Legend]
    Node = Vec2
    Edge = seq[Node]



## global variables and initial setup
region(globals):
  var
    curPos = (0, 0).Vec2
    labMap: LabyrinthMap
    xMin, xMax, yMin, yMax: int
    nodes: HashSet[Node]
    edges: HashSet[Edge]

  labMap[curPos] = space
  nodes.incl curPos

# step, lookAround
region(basics):
  proc extendBoundaries(v: Vec2) =
    if v.x < xMin:
      xMin = v.x
    elif v.x > xMax:
      xMax = v.x
    if v.y < yMin:
      yMin = v.y
    elif v.y > yMax:
      yMax = v.y

  proc toVec2(d: Direction): Vec2 =
    case d:
      of dirNorth: (0, 1)
      of dirEast: (1, 0)
      of dirSouth: (0, -1)
      of dirWest: (-1, 0)

  proc `+`(v, w: Vec2): Vec2 = (v.x + w.x, v.y + w.y)

  proc `+`(v: Vec2, d: Direction): Vec2 = v + d.toVec2

  proc step(d: Direction): Legend =
    p.inQ.push d.ord
    discard p.run
    case p.outQ.pop:
      of wall.ord:
        result = wall
      of space.ord:
        result = space
      of oxygen.ord:
        result = oxygen
      else:
        raise ValueError.newException "do not understand output"
    labMap[curPos + d] = result
    if result != wall:
      curPos = curPos + d
    extendBoundaries(curPos + d)

  proc showMap: string =
    for y in countdown(yMax, yMin):
      for x in countup(xMin, xMax):
        if (x, y) notin labMap:
          result &= " "
        elif (x, y) == curPos:
          result &= "D"
        else:
          case labMap[(x, y)]:
            of wall:
              result &= "#"
            of space:
              result &= "."
            of oxygen:
              result &= "O"
      result &= "\n"

  proc opposite(d: Direction): Direction =
    case d:
      of dirNorth:
        dirSouth
      of dirSouth:
        dirNorth
      of dirEast:
        dirWest
      of dirWest:
        dirEast

  proc stepBack(d: Direction) =
    if step(opposite(d)) == wall:
      raise ValueError.newException "running into a wall while stepping back"

  proc seen(d: Direction): bool = curPos + d in labMap

  proc lookAround : seq[Direction] =
    ## returns unseen and non wall directions
    for d in Direction:
      if not d.seen and d.step != wall:
        result.add d
        d.stepBack

## graph stuff
proc makeEdge(d: Direction): seq[Direction] =
  assert curPos in nodes
  assert labMap[curPos + d] in [space, oxygen]  # assumed I already know that I can proceed in that direction
  var
    edge: Edge
    d = d
  edge.add curPos  # starting node
  while true:
    if d.step == oxygen:  # performs step during if
      result = lookAround()
      break
    result = lookAround()
    if result.len != 1:
      break
    d = result[0]
    edge.add curPos
  edge.add curPos  # ending node

proc explore(newDirs: seq[Direction]) =
  discard

discard lookAround()
echo showMap()
echo makeEdge(dirSouth)
echo showMap()
    
  