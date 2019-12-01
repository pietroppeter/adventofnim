import strutils, sequtils, math

let input = "day01.txt".readFile.splitLines.map parseInt

proc computeFuel(mass: int): int =
  max(mass div 3 - 2, 0)

assert 12.computeFuel == 2
assert 14.computeFuel == 2
assert 1969.computeFuel == 654
assert 100756.computeFuel == 33583

echo "Part 1"
echo "Total fuel: ", sum(input.map computeFuel)

proc recomputeFuel(mass: int): int =
  result = computeFuel(mass)
  var fuelMass = result
  # walrus operator in nim: https://forum.nim-lang.org/t/4637
  while (fuelMass = computeFuel(fuelMass); fuelMass) > 0:
    result += fuelMass

assert 14.recomputeFuel == 2
assert 1969.recomputeFuel == 966  
assert 100756.recomputeFuel == 50346

echo "Part 2"
echo "Total fuel: ", sum(input.map recomputeFuel)
