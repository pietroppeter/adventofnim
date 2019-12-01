import strutils

let input = readFile("2017/day01.txt")

proc solve(input: string; next = 1): int =
  for i, c in input.pairs:
    if c == input[(i + next) mod input.len]:
      result += ($c).parseInt

echo "part1: ", solve(input)

echo "part2: ", solve(input, next = input.len div 2)

assert solve("1122") == 3
assert solve("1111") == 4
assert solve("1234") == 0
assert solve("91212129") == 9