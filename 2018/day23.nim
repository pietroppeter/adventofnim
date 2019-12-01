import strutils, sequtils, strscans

let input = "2018/day23.txt".readFile.splitLines

echo "# nanobots: ", input.len

type
  Nanobot = object
    x, y, z, r: int

proc parseBots(line: string): Nanobot =
  if not scanf(line, "pos=<$i,$i,$i>, r=$i", result.x, result.y, result.z, result.r):
    raise newException(ValueError, "cannot parse " & line)

assert "pos=<0,0,0>, r=4".parseBots == Nanobot(x: 0, y:0, z: 0, r: 4)

let 
  example = """pos=<0,0,0>, r=4
pos=<1,0,0>, r=1
pos=<4,0,0>, r=3
pos=<0,2,0>, r=1
pos=<0,5,0>, r=3
pos=<0,0,3>, r=1
pos=<1,1,1>, r=1
pos=<1,1,2>, r=1
pos=<1,3,1>, r=1"""
  exampleBots = example.splitLines.map(parseBots)

proc strongest(bots: seq[Nanobot]): Nanobot =
  let
    rSeq = bots.mapIt(it.r)
    i = rSeq.find(max(rSeq))
  bots[i]

echo exampleBots.strongest

proc inRange(this, that: Nanobot): bool =
  abs(this.x - that.x) + abs(this.y - that.y) + abs(this.z - that.z) <= this.r

proc inRange(this: Nanobot, bots: seq[Nanobot]): int =
  for that in bots:
    if this.inRange(that):
      inc result

echo exampleBots.strongest.inRange(exampleBots)

let
  inputBots = input.map(parseBots)
  inputStrongest = inputBots.strongest

echo inputStrongest
echo "part 1: ", inputStrongest.inRange(inputBots)
