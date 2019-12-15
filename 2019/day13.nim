import intcode, tables, deques  # I probably should export deques in intcode

var p = "2019/day13.txt".readFile.parseProgram

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

let finalScreen = p.outQ.parseDrawCommands.run

var countBlockTile = 0
for k, v in finalScreen:
  if v == 2:
    inc countBlockTile

# echo finalScreen
echo "part 1: ", countBlockTile
assert countBlockTile == 298
