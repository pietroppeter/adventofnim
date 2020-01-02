import strutils

const base = [0, 1, 0, -1]

proc pattern(k: int, l: int): seq[int] =
  var j = 0
  if k == 0:
    j = 1
  for i in 2 .. (l + 1):
    result.add base[j]
    if i mod (k + 1) == 0:
      j = (j + 1) mod 4

# simple patterns
for k in 0 .. 7:
  echo pattern(k, 8)

proc fft(s: seq[int]): seq[int] =
  let l = s.len
  result.setLen(l)
  for k in 0 ..< l:
    for i, m in k.pattern l:
      result[k] += s[i]*m
    result[k] = abs(result[k]) mod 10

var signal = @[1,2,3,4,5,6,7,8]
for p in 1 .. 4:
  signal = signal.fft
  echo signal

const offset = '0'.ord

proc parse(text: string): seq[int] =
  for c in text:
    result.add c.ord - offset

echo "80871224585914546619083218645595".parse

proc solve(text: string; part2 = false): string =
  var signal = text.parse
  var offset = 0
  if part2:
    offset = text[0 .. 6].parseInt
    for i in 2 .. 10_000:
      signal &= signal

  for i in 1 .. 100:
    signal = signal.fft

  for i in 0 .. 7:
    result.add $signal[i + offset]

echo "80871224585914546619083218645595".solve
assert "80871224585914546619083218645595".solve == "24176176"

let input = "2019/day16.txt".readFile
echo input.solve  # 30369587
echo input.solve(part2=true)  # out of memory!


