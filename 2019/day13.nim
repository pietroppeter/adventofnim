import intcode, tables, deques  # I probably should export deques in intcode

let p13 = "2019/day13.txt".readFile.parseProgram

var p = p13

echo "n steps: ", p.run
echo "outQ.len: ", p.outQ.len
echo "outQ.len mod 3: ", p.outQ.len mod 3

type
  DrawCommand = tuple[x,y,id: int]
  Screen = Table[tuple[x,y: int], int]

proc parseDrawCommands(o: var Queue): seq[DrawCommand] =  
  while o.len > 0:
    result.add (o.pop, o.pop, o.pop)

proc run(s: seq[DrawCommand]): Screen =
  for d in s:
    result[(d.x, d.y)] = d.id

proc update(screen: var Screen, changes: seq[DrawCommand]) =
  for c in changes:
    screen[(c.x, c.y)] = c.id

let finalScreen = p.outQ.parseDrawCommands.run

var countBlockTile = 0
for k, v in finalScreen:
  if v == 2:
    inc countBlockTile

echo "part 1: ", countBlockTile
assert countBlockTile == 298

var ymax, xmax = 0

proc findMax(s: Screen):  tuple[x, y: int] =
  for k in s.keys():
    if k.x > result.x:
      result.x = k.x
    if k.y > result.y:
      result.y = k.y

proc `$`(s: Screen): string =
  if (-1, 0) in s:
    result = "score: " & $s[(-1, 0)] & "\n"
  let
    (xmax, ymax) = s.findMax
  for y in 0 .. ymax:
    for x in 0 .. xmax:
      if (x, y) notin s:
        result &= " "
        continue
      case s[(x, y)]:
        of 0:
          result &= " "
        of 1:
          result &= "@"
        of 2:
          result &= "O"
        of 3:
          result &= "="
        of 4:
          result &= "*"
        else:
          raise ValueError.newException "object unknown: " & $s[(x, y)]
    result &= "\n"  

echo $finalScreen

p = p13
p.mem[0] = 2

var
  screen: Screen
  cmd: string

while not p.isHalted:
  discard p.run
  screen.update p.outQ.parseDrawCommands
  echo $screen
  cmd = readLine(stdin)
  case cmd:
    of "s":
      p.inQ.push -1
    of "d":
      p.inQ.push 1
    of "e":
      break
    else:
      p.inQ.push 0

