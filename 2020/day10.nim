import algorithm, sequtils, parseutils, strutils, tables
import sugar

let example1 = """16
10
15
5
1
11
7
19
6
12
4"""

proc parse(text: string): seq[int] =
  result = @[0] & text.strip.splitLines.map(parseInt)
  result.sort
  result.add result[^1] + 3

proc solve1(s: seq[int]): (int, int) =
  for i in 1 .. s.high:
    #dump (i, s[i], s[i - 1], s[i] - s[i - 1])
    if (s[i] - s[i-1]) == 1:
      inc result[0]
    elif (s[i] - s[i-1]) == 3:
      inc result[1]
    elif (s[i] - s[i-1]) > 3 or (s[i] - s[i-1]) == 0:
      echo "ERROR I do not expect differences > 3 or == 0. (i, s[i], s[i - 1]):", (i, s[i], s[i - 1])

echo example1.parse.solve1 # (7, 5)

let example2 = """28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3"""

echo example2.parse.solve1

let
  input = "2020/input10.txt".readFile
  part1 = input.parse.solve1

echo part1
echo part1[0]*part1[1]
#(68, 27)
#1836

discard """

I also checked all adapters are different (above check == 0)

trick to second part: to count the number of arrangement I split in subsequence every time a difference is == 3
the two elements that are of distance == 3 cannot be skipped
the number of arrangement of total sequence is the product of the number of arrangements of the different subsequences!

for the subsequences themselves I will use a recursive approach:
  - I pick the first element that can be skipped and I count the number of arrangements with or without it (possibly splitting in 2 subsequences)

in order to make the recursive approach more efficient, I will use memoization in my counting proc and
reduce its input to a sequence of differences.

I will do a simple memoization by using a global table (and I do not even need to reset it between examples and inputs!)

can a table have as key a sequence of differences?
"""

var memo: Table[seq[int], int]
memo[@[1, 1]] = 2
memo[@[2, 1]] = 2
memo[@[1, 2]] = 2

proc numArr(ds: seq[int]): int =
  ## input is a sequence of differences.
  ## for all d in ds 0 < d <= 3 
  result = 1
  if ds.len <= 1: return
  # check if there are 3s or two succesive 2s at the beginning or end
  if ds[0] == 3:
    return numArr(ds[1 .. ^1])
  if ds[^1] == 3:
    return numArr(ds[0 ..< ^1])
  if ds[0] == 2 and ds[1] == 2:
    return numArr(ds[2 .. ^1])
  if ds[^1] == 2 and ds[^2] == 2:
    return numArr(ds[0 ..< ^2])
  # check if there are 3s or two succesive 2s inside the sequence
  for i in 1 ..< ds.high:
    # if we get in here then len > 2
    if ds[i] == 3:
      return numArr(ds[0 ..< i])*numArr(ds[(i+1) .. ^1])
    if ds[i] == 2 and ds[i+1] == 2:
      return numArr(ds[0 ..< i])*numArr(ds[(i+2) .. ^1])
  # if there are no threes check if I computed already:
  if ds in memo:
    return memo[ds]
  # if we get sure for sure len > 2 (because of previous checks and memo initialization)
  # otherwise reduce length using numArr(@[x y s]) = numArr(@[y s]) + numArr(@[x+y s])
  result = numArr(ds[1 .. ^1]) + numArr(@[ds[0] + ds[1]] & ds[2 .. ^1])
  memo[ds] = result
  # do not need to return here

proc diff(s: seq[int]): seq[int] =
  for i in 1 .. s.high:
    result.add s[i] - s[i-1]

proc solve2(s: seq[int]): int = s.diff.numArr

echo example1.parse.solve2
echo example2.parse.solve2
echo input.parse.solve2
#8
#19208
#43406276662336
