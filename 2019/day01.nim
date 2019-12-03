import strutils, sequtils, math

let input = "2019/day01.txt".readFile.splitLines.map parseInt

proc computeFuel(mass: int): int = max(mass div 3 - 2, 0)

echo "part 1: ", sum(input.map computeFuel)

proc recomputeFuel(mass: int): int =
  result = computeFuel(mass)
  if result > 0:
    return result + recomputeFuel(result)

echo "part 2: ", sum(input.map recomputeFuel)

assert 12.computeFuel == 2
assert 14.computeFuel == 2
assert 1969.computeFuel == 654
assert 100756.computeFuel == 33583

assert 14.recomputeFuel == 2
assert 1969.recomputeFuel == 966  
assert 100756.recomputeFuel == 50346
