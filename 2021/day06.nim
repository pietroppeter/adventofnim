import animu
include "2021/input06.txt"
echo puzzleInput.len
# generate simulation for a single fish that has 1 as time

#[
  1: 2, 9, 16, ...
  ..
  4: 5, 12, 19, ...
  ..
  8: 8, 15, 22, ...

a: cycle age
s: start time
t: target time
f(a, s, t): number of generated fish at t from a fish of age a at time s
f(a, s, t) = f(a, 0, t - s)
f(a + b, s, t) = f(a, s, t - b)
f(0, 0, 0) = 0
f(0, 0, 1) = 1

F(a1, ..., aN, t): tot number of gen fish at time t from fishes of "ages" a1, ... aN at time 0
F(a1, ..., aN, t) = f(a1, 0, t) + ... + f(aN, 0, t)
if b1, ... b5 are numbers of ai = 1, ... numbers of ai = 5 (as in input), then
F(a1, ..., aN, t) = b1*f(1, 0, t) + ... + b5*f(5, 0, t)
f(5, 0, t) = f(1, 0, t - 4)
]#

proc tick(school: seq[int]): seq[int] =
  result = newSeqWith(len=school.len): -1
  for i, a in school:
    if a == 0:
      result[i] = 6
      result.add 8
    else:
      result[i] = a - 1

func part1(input: seq[int], targetTime=80): (int, seq[int]) =
  # input ages are only between 1 and 5
  var
    counts: array[0 .. 8, int]
    values: array[0 .. 8, int]
  for a in input:
    assert a in 0 .. 8
    inc counts[a]
  var school = @[1]
  for t in 1 .. targetTime:
    school = tick school
    if t >= targetTime - 4:
      let i = targetTime - t + 1
      assert i in 0 .. 8
      values[i] = school.len
  for i in 0 .. 8:
    result[0] += counts[i]*values[i]
  result[1] = school

let testInput = @[3, 4, 3, 1, 2]  
doAssert part1(testInput)[0] == 5934
dump part1(puzzleInput)[0] # 387413

#[
  G(i, t) = [G0(i, t), ... G8(i, t)]
  G0: how many 0 I have at time t starting from i (i in 0 .. 8)
  compute G for all i in 0 .. 8 and for a fixed time t
]#

func g(chunkTime: int): array[9, array[9, int]] =
  var
    school: seq[int]
  for i in 0 .. 8:
    school = @[i]
    for t in 1 .. chunkTime:
      school = tick school
    for j in school:
      inc result[i][j]

let chunk = g(16)
for i in 0 .. 8:
  echo "i: ", i, "; results: ", chunk[i]


# part2 requires a different approach
# let's try to chunk 16 steps at the time
func part2(input: seq[int], chunk=16, times=16): int =
  var
    counts: array[0 .. 8, int]
    countsNext: array[0 .. 8, int]
  for i in input:
    assert i in 0 .. 8
    inc counts[i]
  let chunkCounts = g(chunk)
  for k in 1 .. times:
    countsNext = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    for i in 0 .. 8:
      for j in 0 .. 8:
        countsNext[j] += counts[i]*chunkCounts[i][j]
    counts = countsNext
  result = sum(counts)

dump part2(testInput)
dump part2(puzzleInput)