include prelude
import sugar

var
  countOnes: array[12, int]
  n: int

for line in "2021/input03.txt".lines:
  inc n
  for i, c in line:
    if c == '1':
      inc countOnes[i]

echo countOnes
echo n

var gamma, epsilon: string
for k in countOnes:
  if k > 500:
    gamma &= "1"
    epsilon &= "0"
  else:
    gamma &= "0"
    epsilon &= "1"

echo parseBinInt(gamma)*parseBinInt(epsilon)

# part 2
let
  binNums = "2021/input03.txt".lines.toSeq
  testNums = """
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010""".splitLines.toSeq

func lifeSupport(nums: seq[string], oxy=true): int =
  var
    nums = nums  # idiomatic
    i = 0
    zeros, ones: seq[int]
  while nums.len > 1:
    zeros = @[]  # zeros, ones = @[] does not work
    ones = @[]
    for j, num in nums:
      if num[i] == '1':
        ones.add j
      else:
        zeros.add j
    #dump ones
    #dump zeros
    if oxy:
      if ones.len >= zeros.len:
        nums = collect:
          for j in ones:
            nums[j]
      else:
        nums = collect:
          for j in zeros:
            nums[j]
    else:
      if zeros.len <= ones.len:
        nums = collect:
          for j in zeros:
            nums[j]
      else:
        nums = collect:
          for j in ones:
            nums[j]
    inc i
    #debugEcho nums
  assert nums.len == 1
  return parseBinInt(nums[0])

func solve2(nums: seq[string]): int =
  lifeSupport(nums)*lifeSupport(nums, false)
echo solve2 testNums
echo solve2 binNums
