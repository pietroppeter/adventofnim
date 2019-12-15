import strscans, strformat, math, strutils, sequtils, algorithm

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

# part 2
# problem can be reduced to one dimension (x)
type
  NamedMoon = tuple[x, v, g: int, name: string]
  JupyMoons = array[4, NamedMoon]

proc cmp(x, y: NamedMoon): int =
  if x < y: -1 else: 1

# overloaded sort does not seem to work with array!
proc sort(m: var JupyMoons) =
  m.sort(cmp)

proc collision(m: JupyMoons): bool =
  # assume sorted
  m[0].x == m[1].x or m[1].x == m[2].x or m[2].x == m[3].x

proc updateGravity(m1, m2: var NamedMoon) =
  if m1.x < m2.x:
    inc m1.g
    dec m2.g
  elif m1.x > m2.x:
    dec m1.g
    inc m2.g

proc computeGravity(m: var JupyMoons) =
  for i in 0 .. 3:
    m[i].g = 0
  for i, j in allPairs(4):
    updateGravity(m[i], m[j])

proc applyGravity(m: var JupyMoons) =
  for i in 0 .. 3:
    m[i].v += m[i].g
    
proc applyVelocity(m: var JupyMoons) =
  for i in 0 .. 3:
    m[i].x += m[i].v

proc step(m: var JupyMoons) =
  computeGravity m
  applyGravity m
  applyVelocity m

proc jump(m: var NamedMoon, s: Natural) =
  # jump ahead to time s with constant gravity, s is chosen so that gravity will not change
  m.x += m.v*s + m.g*s*(s + 1) div 2
  m.v += m.v + m.g*s

proc jump(m: var JupyMoons, s: Natural) =
  for i in 0 .. 3:
    jump m[i], s

proc minCrossTime(m1, m2: NamedMoon): Natural =
  # assume m1.x < m2.x
  # I know that at time t:
  # m1.x(t) = m1.x + m1.v*t + m1.g*t*(t + 1) div 2
  # and similar for m2.x(t) where:
  # I have that m2.g = m1.g - 2
  # find minimal s > 0 such that m1.x(s) >= m2.x(s)
  # the eq for which m1.x(s) == m2.x(s) is:
  # (m2.x - m1.x) + (m2.v - m1.v)*t - t*(t +1) = 0  (since m2.g - m1.g -> -2)
  # t^2 + (m1.v - m2.v + 1)*t + (m1.x - m2.x)  and we have a = 1 and c < 0 so we have two real solution and the only positive one is:
  # (-b + sqrt(b^2 -4c))/2
  let
    b = m1.v - m2.v + 1
    c = m1.x - m2.x
    delta = b^2 - 4*c
    t = 0.5*(-b.float + sqrt(delta.float))
  ceil(t).int

proc minCrossTime(m: JupyMoons): Natural =
  var s: int
  result = Natural.high
  for i in 0 .. 2:
    s = minCrossTime(m[i], m[i + 1])
    if s < result:
      result = s

proc isPeriodReachable(m1, m2: NamedMoon, s: var int): bool =
  # m1.x(t) = m2.x (does not move, it is initial position)
  # m1.g*t^2 + (2*m1.v + m1.g)*t + 2*(m1.x - m2.x) = 0
  var
    m1 = m1
    t: int
  let
    a = m1.g
    b = 2*m1.v + m1.g
    c = 2*(m1.x - m2.x)
    delta = b^2 - 4*a*c
  if delta < 0:
    return false
  t = (0.5*(b.float + sqrt(delta.float))/a.float).int
  jump m1, t
  if m1 != m2:
    return false
  s = t
  return true

proc isPeriodReachable(m, moons: JupyMoons, s: var int): bool =
  var m = m
  # first they will have to be in same order:
  for i in 0 .. 3:
    if m[i].name != moons[i].name:
      return false
  if not isPeriodReachable(m[0], moons[0], s):
    return false
  for i in 1 .. 3:
    jump m[i], s
    if m[i] != moons[i]:
      return false

proc period(moons: JupyMoons): int =
  assert moons.isSorted(cmp)
  var
    m = moons
    t = 1
    s: int
  step m
  sort m
  while m != moons:
    echo "t = " & $t
    if m.collision:
      echo "collision at t = " & $t
      step m
      sort m
      inc t
      continue
    s = minCrossTime(m)
    echo "mincrosstime: " & $s
    if isPeriodReachable(m, moons, s):
      # if true, s will be changed to time to period
      return t + s
    jump m, s
    t += s
    sort m

bodies1 = inp1.parseBodies

proc to3dJupyMoons(b: Bodies): array[3, JupyMoons] =
  for i in 0 .. 3:
    result[0][i].x = b[i].pos.x
    result[1][i].x = b[i].pos.y
    result[2][i].x = b[i].pos.z
    result[0][i].v = b[i].vel.x
    result[1][i].v = b[i].vel.y
    result[2][i].v = b[i].vel.z
  for j in 0 .. 2:
    sort result[j]

var jm1 = bodies1.to3dJupyMoons

proc period(b: array[3, JupyMoons]): int =
  var p: seq[int]
  for i in 0 .. 2:
    p.add period b[i]
    echo p[i]
  return lcm(lcm(p[0], p[1]), p[2])

echo "period test 1: ", period jm1