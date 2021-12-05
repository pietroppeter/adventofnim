import animu

proc parse(text: string): seq[(int, int, int, int)] =
  for line in text.splitLines:
    let (success, x1, y1, x2, y2) = scanTuple(line, "$i,$i -> $i,$i")
    assert success
    result.add (x1, y1, x2, y2)

var points = initCountTable[(int, int)]()
let lineCoords = "2021/input05.txt".readFile.parse
echo lineCoords[0 .. 10]
echo len(lineCoords)
var countOverlaps: int
for (x1, y1, x2, y2) in lineCoords:
  if x1 == x2:
    for y in min(y1, y2) .. max(y1, y2):
      points.inc (x1, y)
      if points[(x1, y)] == 2:
        inc countOverlaps
  elif y1 == y2:
    for x in min(x1, x2) .. max(x1, x2):
      points.inc (x, y1)
      if points[(x, y1)] == 2:
        inc countOverlaps
  elif abs(x2 - x1) == abs(y2 - y1):
    var xInc, yInc: int
    if x1 <= x2:
      xInc = 1
    else:
      xInc = -1
    if y1 <= y2:
      yInc = 1
    else:
      yInc = -1
    var x, y: int
    for i in 0 .. abs(x2 - x1):
      if i == 0:
        x = x1
        y = y1
      else:
        x += xInc
        y += yInc
      points.inc (x, y)
      if points[(x, y)] == 2:
        inc countOverlaps
  else:
    echo "ERR: ", (x1, x2, y1, y2)
echo countOverlaps