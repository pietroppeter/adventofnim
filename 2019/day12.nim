import strscans, strformat, math, strutils, sequtils

let inp1 = """<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>"""
let inp2 = """<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>"""
# my input:
let inp0 = """<x=15, y=-2, z=-6>
<x=-5, y=-4, z=-11>
<x=0, y=-6, z=0>
<x=5, y=9, z=6>"""

type
  Vec3 = tuple[x, y, z: int]
  Moon = tuple[pos, vel: Vec3]
  Bodies = seq[Moon]

proc parseBodies(inp: string): Bodies =
  var moon: Moon
  for line in inp.splitLines:
    if not scanf(line, "<x=$i, y=$i, z=$i>", moon.pos.x, moon.pos.y, moon.pos.z):
      raise ValueError.newException "error parsing line: " & line
    result.add moon

proc `$`(bodies: Bodies): string =
  # how to align better pos e vels?
  for b in bodies:
    result.add fmt"pos=<x={b.pos.x}, y={b.pos.y}, z={b.pos.z}>, vel=<x={b.vel.x}, y={b.vel.y}, z={b.vel.z}>" & "\n"


var
  bodies0 = inp0.parseBodies
  bodies1 = inp1.parseBodies
  bodies2 = inp2.parseBodies

echo $bodies1

iterator allPairs(n: Natural): tuple[i, j: int] =
  for i in 0 ..< n:
    for j in (i + 1) ..< n:
      yield (i, j)

proc gravity(c1, c2: int): tuple[g1, g2: int] =
  if c1 < c2:
    return (1, -1)
  elif c1 > c2:
    return (-1, 1)
  else:
    return (0, 0)

proc gravity(m1, m2: var Moon) =
  var g1, g2: int
  (g1, g2) = gravity(m1.pos.x, m2.pos.x)
  m1.vel.x += g1
  m2.vel.x += g2
  (g1, g2) = gravity(m1.pos.y, m2.pos.y)
  m1.vel.y += g1
  m2.vel.y += g2
  (g1, g2) = gravity(m1.pos.z, m2.pos.z)
  m1.vel.z += g1
  m2.vel.z += g2

proc step(b: var Bodies) =
  for i, j in allPairs(b.len):
    gravity(b[i], b[j])
  for i in 0 ..< b.len:
    b[i].pos.x += b[i].vel.x
    b[i].pos.y += b[i].vel.y
    b[i].pos.z += b[i].vel.z

proc step(bodies: var Bodies, n: Natural) =
  for s in 1 .. n:
    bodies.step

bodies1.step
echo $bodies1
bodies1.step
echo $bodies1
bodies1.step 8
echo $bodies1

proc energy(v: Vec3): Natural =
  v.x.abs + v.y.abs + v.z.abs

proc energy(m: Moon): Natural =
  m.pos.energy * m.vel.energy

proc energy(bodies: Bodies): Natural =
  for moon in bodies:
    result += moon.energy

echo bodies1.energy
bodies2.step 100
echo bodies2.energy

bodies0.step 1000
echo "part 1: ", bodies0.energy