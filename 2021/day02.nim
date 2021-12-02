import nimib, animu

nbInit(theme=useAdventOfNim)
nbText: """## Day 2: Dive! 
"""
block part1:
  echo "part1"
  var pos: tuple[x, d: int]
  template down(n: int) = pos.d += n
  template up(n: int) = pos.d -= n
  template forward(n: int) = pos.x += n
  template reset = pos = (0, 0)
  template solve = echo pos.x*pos.d
  # test input
  forward 5
  down 5
  forward 8
  up 3
  down 8
  forward 2
  # test solution
  solve
  # real input
  reset
  include input02
  solve

block part2:
  echo "part2"
  var pos: tuple[x, d, a: int]
  template down(n: int) = pos.a += n
  template up(n: int) = pos.a -= n
  template forward(n: int) =
    pos.x += n
    pos.d += pos.a*n
  template reset = pos = (0, 0, 0)
  template solve = echo pos.x*pos.d
  # test input
  echo pos
  forward 5
  echo pos
  down 5
  echo pos
  forward 8
  echo pos
  up 3
  echo pos
  down 8
  echo pos
  forward 2
  echo pos
  # test solution
  solve
  # real input
  reset
  include input02
  solve
