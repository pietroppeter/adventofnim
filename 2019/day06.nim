import sets, tables, sequtils, strutils, strformat, hashes

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
  Universe = HashSet[AstroBody]

proc isRoot(obj: AstroBody): bool =
  if obj.sun == nil:
    return true

proc isLeave(obj: AstroBody): bool =
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
  if obj.isLeave:
    result.add "Leave"
  else:
    result.add $obj.moons

proc hash(obj: AstroBody): Hash = hash(obj,name)

var com = AstroBody(name: "COM")

echo com
echo com.repr

var uom: Universe

uom.incl(com)

proc parseOrbit(l: string): tuple[sun: string, moon: string] =
  let s = l.split(")")
  if s.len != 2:
    raise newException(ValueError, "Error parsing line: " & l)
  return (s[0], s[1])

echo "COM)B".parseOrbit
echo "21X)BMW".parseOrbit


