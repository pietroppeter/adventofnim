import nimib

nbInit

nbText: "# 2019 - Day 01"

nbText: "I should probably do an include prelude..."
nbCode:
  import strutils, sequtils, math

nbText: "loading input:"
nbCode:
  let input = "2019/day01.txt".readFile.splitLines.map parseInt
  echo input.len
  echo input[0 .. 9], "\n...\n", input[^10 .. ^1]

nbText: "## Part1\nsolution:"
nbCode:
  proc computeFuel(mass: int): int = max(mass div 3 - 2, 0)
  echo sum(input.map computeFuel)

nbText: "## Part2\nsolution:"
nbCode:
  proc recomputeFuel(mass: int): int =
    result = computeFuel(mass)
    if result > 0:
      return result + recomputeFuel(result)

  echo sum(input.map recomputeFuel)

nbText: "## Tests"

nbCode:
  assert 12.computeFuel == 2
  assert 14.computeFuel == 2
  assert 1969.computeFuel == 654
  assert 100756.computeFuel == 33583

  assert 14.recomputeFuel == 2
  assert 1969.recomputeFuel == 966  
  assert 100756.recomputeFuel == 50346

nbSave