import strutils, sequtils, math, sets

let input = "day01.txt".readFile.splitLines.map parseInt

echo "part 1: ", sum(input)

echo "input.len = ", input.len

var
  frequency = 0
  seen = initHashSet[int](2^18)  # with low value, e.g. 10, you can see slowing down through cycles!
seen.incl(frequency)

iterator cyclic(s: seq[int]): int =
  var
    i = s.low
    n = 0
  while true:
    yield s[i]
    inc i
    if i > s.high:
      inc n
      debugEcho "cycle: ", n
      i = s.low 

for change in input.cyclic:
  frequency += change
  if frequency in seen:
    break
  seen.incl(frequency)

echo "part 2: ", frequency