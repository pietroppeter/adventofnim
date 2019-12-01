let input = "./2015/day01.txt".readFile

var floor: int

for p in input:
  if p == '(':
    inc floor
  else:
    dec floor

echo "part 1: ", floor

floor = 0

for i, p in input:
  if p == '(':
    inc floor
  else:
    dec floor
  if floor == -1:
    echo "part 2: ", i + 1
    break
