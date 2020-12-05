import parseutils, strutils, algorithm

type Seat = int16

proc parseSeat(s: string): Seat =
  discard parseBin[int16](s.multiReplace([("F", "0"), ("B", "1"), ("R", "1"), ("L", "0")]), result)

var
  maxSeat = 0
  seats: seq[Seat]
for line in "2020/input05.txt".lines:
  seats.add parseSeat(line)
  if seats[^1] > maxSeat:
    maxSeat = seats[^1]
echo "part1: ", maxSeat

seats.sort()
for x in 1 ..< seats.len:
  if seats[x] != seats[x - 1] + 1:
    echo "part2: ", seats[x] - 1

