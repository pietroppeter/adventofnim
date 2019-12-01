import strscans, strutils

let input = "2015/day02.txt".readFile.splitLines

var
  paper, ribbon, l, w, h: int

proc wrap(l, w, h: int): int = 2*l*w + 2*w*h + 2*l*h + min([l*w, w*h, l*h])

proc tie(l, w, h: int): int = l*w*h + 2*min([l + w, w + h, l + h])

assert wrap(2, 3, 4) == 58
assert wrap(1, 1, 10) == 43

assert tie(2, 3, 4) == 34
assert tie(1, 1, 10) == 14

for line in input:
  if not scanf(line, "$ix$ix$i", l, w, h):
    echo "error: ", line
    break
  paper += wrap(l, w, h)
  ribbon += tie(l, w, h)

echo "part 1: ", paper
echo "part 2: ", ribbon