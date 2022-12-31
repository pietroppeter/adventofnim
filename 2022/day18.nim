import batteries, aoc22, nimib, p5
let day = Day(
  num: 18,
  title: "Boiling Boulders",
  summary: ""
)
nbInit
nbUseP5
nbJsFromCode:
  import p5aoc
nb.darkMode
nbText: day.mdTitle

nbPart1

let dayInput = day.filename.readFile
nbText: """
The strategy I will use to solve part1 is simple:
  - put cubes in a HashSet of tuples
  - for every cube, count how many neighbours are not in the the HashSet

I need to define the types:
"""
nbCode:
  type
    Vec3 = tuple[x, y, z: int]
    Vec3Set = HashSet[Vec3]

nbText: "parsing input"
nbCode:
  func parse(text: string): Vec3Set =
    for line in text.splitLines:
      let ints = line.split(",").mapIt(parseInt it)
      assert len(ints) == 3
      result.incl (ints[0], ints[1], ints[2])
  
  let cubes = parse dayInput
  echo len cubes
  for i, cube in enumerate(cubes):
    echo cube
    if i == 3:
      break
nbText: "I redo this kind of stuff every year, but I am too lazy to put them in a library:"
nbCode:
  func `+`(v, w: Vec3): Vec3 =
    (v.x + w.x, v.y + w.y, v.z + w.z)

  func `-`(v, w: Vec3): Vec3 =
    (v.x - w.x, v.y - w.y, v.z - w.z)

  iterator neighbours(v: Vec3): Vec3 =
    for w in [(1, 0, 0), (0, 1, 0), (0, 0, 1)]:
      yield v + w
      yield v - w

  for v in neighbours((0, 0, 0)):
    echo v
nbText: "now let's count"
nbCode:
  let example = """
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5"""

  func part1(text: string): int =
    let cubes = parse text
    for cube in cubes:
      for neighbour in cube.neighbours:
        if neighbour not_in cubes:
          inc result

  echo part1 example # expect 64
  echo part1 dayInput
gotTheStar

nbPart2
nbText: """
The idea for part2 is to build a set of cubes that
represents the exterior shell of the lava droplet and count them.

- start from a cube that I know that is part of exterior shell
- build shell by iterating over neighbours (that are not already in shell)
"""
nbCode:
  func startingPoint(cubes: Vec3Set): Vec3 =
    var minXcube: Vec3 = (1000, 0, 0) # conveniently high number
    for cube in cubes:
      if cube.x < minXcube.x:
        minXcube = cube
    return minXcube - (1, 0, 0)

  func pick(cubes: Vec3Set): Vec3 =
    for cube in cubes:
      return cube

  iterator neighboursAll(cube: Vec3): Vec3 =
    for v in cube.neighbours:
      yield v
    for w in [(1, 1, 0), (1, -1, 0), (1, 0, 1), (1, 0, -1), (0, 1, 1), (0, 1, -1), (1, 1, 1), (1, -1, 1), (1, 1, -1), (1, -1, -1)]:
      yield cube + w
      yield cube - w

  func isAdjacentTo(cube: Vec3, cubes: Vec3Set): bool =
    if cube in cubes:
      return false
    for v in cube.neighbours:
      if v in cubes:
        return true

  func shell(cubes: Vec3Set): Vec3Set =
    var border = initHashSet[Vec3]()
    border.incl cubes.startingPoint
    var currentCube: Vec3
    while len(border) > 0:
      currentCube = pick border
      for candidate in currentCube.neighboursAll:
        if candidate.isAdjacentTo(cubes) and candidate notIn result:
          border.incl candidate
      result.incl currentCube
      border.excl currentCube    
nbCodeInBlock:
  func part2(text: string): int =
    let cubes = parse text
    let shell = shell(cubes)
    len shell

  echo part2 example
  echo part2 dayInput
nbText: """
part2 is not correct for the example and I suspect this is due to the fact
that I found a shell from part of the lava but there might be other pieces
of lava not inside my shell.

In order to fix this I could iterate my shell finding by removing all cubes
inside my first shell and add further shells.

To find whether a cube is inside my shell is a bit tricky but I can
use a consequence of [Jordan curve theorem](https://en.wikipedia.org/wiki/Jordan_curve_theorem).
If I take a semi infinite line from the cube towards infinity and
count the times it intersects my shell, an even number (including 0) would mean
that I am on the exterior.

I do need to be careful that I have to pick a line that is not "tangent" to my shell
(i.e. all intersections should not be adjacent), but hopefully
at least one of the 6 semilines parallel to x, y, z axis does the trick.
"""
nbCode:
  type
    🤷 = object of CatchableError
    BoundedVec3Set = object
      data: Vec3Set
      xMin, xMax, yMin, yMax, zMin, zMax: int
  
  func bound(cubes: Vec3Set): BoundedVec3Set =
    result.data = cubes
    assert len(cubes) > 0
    # initialize bounds using one cube
    let one = pick cubes
    result.xMin = one.x
    result.xMax = one.x
    result.yMin = one.y
    result.yMax = one.y
    result.zMin = one.z
    result.zMax = one.z
    for cube in cubes:
      if cube.x < result.xMin:
        result.xMin = cube.x
      if cube.y < result.yMin:
        result.yMin = cube.y
      if cube.z < result.zMin:
        result.zMin = cube.z
      if cube.x > result.xMax:
        result.xMax = cube.x
      if cube.y > result.yMax:
        result.yMax = cube.y
      if cube.z > result.zMax:
        result.zMax = cube.z

  func isWithinBounds(cube: Vec3, shell: BoundedVec3Set): bool =
    cube.x >= shell.xMin and cube.x <= shell.xMax and cube.y >= shell.yMin and cube.y <= shell.yMax and cube.z >= shell.zMin and cube.z <= shell.zMax

  func isInside(cube: Vec3, shell: BoundedVec3Set, dir: Vec3): bool =
    var
      intersections = 0
      justIntersected = false
      cube = cube
    while cube.isWithinBounds(shell):
      cube = cube + dir
      if cube in shell.data:
        inc intersections
        if justIntersected:
          raise newException(🤷, "Cannot tell (tangent line)")
        justIntersected = true
      else:
        justIntersected = false
    return not(intersections mod 2 == 0)

  func isInside(cube: Vec3, shell: BoundedVec3Set): bool =
    for dir in [(1, 0, 0), (0, 1, 0), (0, 0, 1), (-1, 0, 0), (0, -1, 0), (0, 0, -1)]:
      try:
        return cube.isInside(shell, dir)
      except 🤷:
        debugEcho "CannotTell in direction: ", dir
    raise newException(🤷, "Cannot tell (all lines tested are tangent)")

  func part2(text: string): int =
    var cubes = parse text
    while len(cubes) > 0:
      let boundedShell = bound shell(cubes)
      result.inc len(boundedShell.data)
      var cubesToRemove = initHashSet[Vec3]()
      for cube in cubes:
        if cube.isInside(boundedShell):
          cubesToRemove.incl cube
      cubes = cubes - cubesToRemove

  echo part2 example
  #echo part2 dayInput

nbText: """Notes:
- I am wrapping my Shell into a bounded shell, so that I do not actually have to go to infinity
- I am using exceptions instead of a ternary type: True, False, can't tell (🤷).
- yes, you can use emoji for identifiers in Nim!
- inheriting directly from `Exception` is now deprecated (warning is "inherit from a more precise exception type like ValueError, IOError or OSError. If these don't suit, inherit from CatchableError or Defect. [InheritFromException]");
  the [manual section on custom exceptions](https://nim-lang.org/docs/manual.html#exception-handling-custom-exceptions) should be updated!
"""
# inheriting from exception is now deprecated (error message says:)
nbSave