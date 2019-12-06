import sets, tables, sequtils, strutils, strformat, hashes, math

let
  input = "2019/day06.txt".readFile.splitLines
  test = "2019/day06test.txt".readFile.splitLines

echo input[0 ..< 10]
echo input.len

type
  AstroBody = ref AstroBodyObj
  AstroBodyObj = object
    name: string
    sun: AstroBody
    moons: seq[AstroBody]
  # Universe = HashSet[AstroBody]
  Map = Table[string, AstroBody]

proc isRoot(obj: AstroBody): bool =
  if obj.sun == nil:
    return true

proc isLeaf(obj: AstroBody): bool =
  if obj.moons.len == 0:
    return true

proc `$`(obj: AstroBody): string =
  obj.name
    
proc repr(obj: AstroBody): string =
  result = obj.name & " "
  if obj.isRoot:
    result.add "Root "
  else:
    result.add "(" & $obj.sun & " "
  if obj.isLeaf:
    result.add "Leaf"
  else:
    result.add $obj.moons

# proc hash(obj: AstroBody): Hash = hash(obj.name)

var com = AstroBody(name: "COM")

echo com
echo com.repr

# var uom: Universe
# uom.incl(com)

proc parseOrbit(l: string): tuple[sun: string, moon: string] =
  let s = l.split(")")
  if s.len != 2:
    raise newException(ValueError, "Error parsing line: " & l)
  return (s[0], s[1])

echo "COM)B".parseOrbit
echo "21X)BMW".parseOrbit

proc parseMap(input: seq[string]): Map =
  var sun, moon: AstroBody
  for line in input:
    let
      orbit = line.parseOrbit
    if result.hasKey(orbit.sun):
      sun = result[orbit.sun]
    else:
      sun = AstroBody(name: orbit.sun)
    if result.hasKey(orbit.moon):
      moon = result[orbit.moon]
    else:
      moon = AstroBody(name: orbit.moon)
    sun.moons.add moon
    if moon.sun != nil:
      raise ValueError.newException fmt"double sun found: {moon.sun}){moon}({sun}"
    moon.sun = sun
    result[orbit.sun] = sun
    result[orbit.moon] = moon

let map = test.parseMap

for body in map.values:
  echo body.repr

proc findRoot(map: Map): AstroBody =
  for body in map.values:
    if body.isRoot:
      return body

let root = map.findRoot

echo root

proc countAllOrbits(body: AstroBody): int =
  if body.isRoot:
    return 0
  result = 1 + body.sun.countAllOrbits  

proc countAllOrbits(map: Map): int =
  for body in map.values:
    result += body.countAllOrbits

echo "part 1 (test): ", map.countAllOrbits
let realMap = input.parseMap
echo "part 1: ", realMap.countAllOrbits

let
  newTest = """COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN"""
  newTestMap = newTest.splitLines.parseMap
  testMe = newTestMap["YOU"]
  testSanta = newTestMap["SAN"]
  me = realMap["YOU"]
  santa = realMap["SAN"]

proc suns(body: AstroBody): seq[string] =
  if body.isRoot:
    return @[]
  return @[body.sun.name] & body.sun.suns

echo testMe.suns, testMe.suns.len
echo testSanta.suns, testSanta.suns.len

proc distance(a, b: AstroBody): int =
  let
    aSuns = a.suns
    bSuns = b.suns
  var i = 1
  while true:
    if aSuns[^i] == bSuns[^i]:
      inc i
    else:
      break
  dec i
  return aSuns.len + bSuns.len - 2*i

echo "part 2 (test): ", testMe.distance(testSanta)
echo "part 2: ", me.distance(santa)