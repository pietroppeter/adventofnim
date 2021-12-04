#? replace(sub="e♭", by="dx")
import nimib, animu

nbInit(theme=useAdventOfNim)

nbText: """## Day 3: [Binary Diagnostic](https://adventofcode.com/2021/day/3)

### Part 1

> The diagnostic report (your puzzle input) consists of a list of binary numbers which, when decoded properly, can tell you many useful things about the conditions of the submarine. The first parameter to check is the _power consumption_.
> 
> You need to use the binary numbers in the diagnostic report to generate two new binary numbers (called the _gamma rate_ and the _epsilon rate_). The power consumption can then be found by multiplying the gamma rate by the epsilon rate.
> 
> Each bit in the gamma rate can be determined by finding the _most common bit in the corresponding position_ of all numbers in the diagnostic report. For example, given the following diagnostic report:
"""

nbCode:
  let testInput = """
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
01010"""

nbText: """
> Considering only the first bit of each number, there are five 0 bits and seven 1 bits. Since the most common bit is 1, the first bit of the gamma rate is 1.
>
> The most common second bit of the numbers in the diagnostic report is 0, so the second bit of the gamma rate is 0.
>
> The most common value of the third, fourth, and fifth bits are 1, 1, and 0, respectively, and so the final three bits of the gamma rate are 110.
>
> So, the gamma rate is the binary number 10110, or _22_ in decimal.
>
> The epsilon rate is calculated in a similar way; rather than use the most common bit, the least common bit from each position is used. So, the epsilon rate is 01001, or _9_ in decimal. Multiplying the gamma rate (22) by the epsilon rate (9) produces the power consumption, _198_.
>
> Use the binary numbers in your diagnostic report to calculate the gamma rate and epsilon rate, then multiply them together. _What is the power consumption of the submarine?_

I had to catch a plane this morning and the puzzle unlocked
while getting onto the plane. Luckily I was able to solve part1 in the few
minutes from the moment I sat on the plane to the moment they asked us
to turn off the devices, so I could get also the text for part2 and had
plenty of time during flight to solve it.
"""
nbCode:
  let
    testNums = testInput.splitLines.toSeq
    puzzleNums = "2021/input03.txt".lines.toSeq

nbCode:
  func getGamma(nums: seq[string]): int =
    var
      gamma = ""
      countOnes: int
    for i in 0 .. nums[0].high:
      countOnes = 0
      for num in nums:
        if num[i] == '1':
          inc countOnes
      if countOnes >= nums.len div 2:
        gamma.add '1'
      else:
        gamma.add '0'
    result = parseBinInt gamma

  dump testNums.getGamma
  dump puzzleNums.getGamma

gotTheStar

nbCode:
  func part1(nums: seq[string]): int =
    let
      gamma = getGamma(nums)
      # 2^5(=32) - 22 - 1 -> 9 
      epsilon = 2^len(nums[0]) - gamma
    return gamma*epsilon

  dump part1 testNums
  dump part1 puzzleNums

nbCode:
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

  func part2(nums: seq[string]): int =
    lifeSupport(nums)*lifeSupport(nums, false)
  dump part2 testNums
  dump part2 puzzleNums

gotTheStar

# add an anchor
nbText: """### Part 3: Whale Music 🐳🎶

[paramidi] -> [paramidib]

[paramidi]: https://github.com/paranim/paramidi
[paramidib]: https://github.com/pietroppeter/paramidib
"""
nbCode:
  import paramidib
  saveMusic("2021/day03test.wav"):
    (piano,
      (tempo: 109), # allegretto
      1/5, 
    # A C D E G    
    # 0 0 1 0 0
      r,r,d,r,r,
    # 1 1 1 1 0
      a,c,d,e,r,
    # 1 0 1 1 0
      a,r,d,e,r,
    # 1 0 1 1 1
      a,r,d,e,g,
    # 1 0 1 0 1
      a,r,d,r,g,
    # 0 1 1 1 1
      r,c,d,e,g,
    # 0 0 1 1 1
      r,r,d,e,g,
    # 1 1 1 0 0
      a,c,d,r,r,
    # 1 0 0 0 0
      a,r,r,r,r,
    # 1 1 0 0 1
      a,c,r,r,g,
    # 0 0 0 1 0
      r,r,r,e,r,
    # 0 1 0 1 0
      r,c,r,e,r   
    )
nbAudio("2021/day03test.wav")

  # blues scale: https://en.wikipedia.org/wiki/Blues_scale
  #12 notes so it is up and down
  #A C D Eb E G
  #rhythm is triplet swing: https://en.wikipedia.org/wiki/Swing_(jazz_performance_style)
  #instrument is saxophone (alto)
  #tempo: 234 Charlie Parker Ornithology (prestissimo)
nbCode:
  # A C D Eb E G
  saveMusic("2021/blues_scale.wav"):
    (altosax,
      (tempo: 234), 2/12,
      -a, c, d, e♭, e, g,
       a, g, e, e♭, d, c,
      -a, c, d, e♭, e, g,
       a, g, e, e♭, d, c,
      2/12, -a, 1/12, c, 2/12, d, 1/12, e♭, 2/12, e, 1/12, g,
      2/12,  a, 1/12, g, 2/12, e, 1/12, e♭, 2/12, d, 1/12, c,
      2/12, -a, 1/12, c, 2/12, d, 1/12, e♭, 2/12, e, 1/12, g,
      2/12,  a, 1/12, g, 2/12, e, 1/12, e♭, 2/12, d, 1/12, c,
    )
nbAudio("2021/blues_scale.wav")
nbCode:
  saveMusic("2021/day03puzzle_head.wav"):
    (altosax,
      (tempo: 234),
      #       1         1         1         1          1         1
      2/12, -a, 1/12, c, 2/12, d, 1/12, e♭, 2/12, e, 1/12, g,
      #       0         1         0         0          1         1
      2/12,  r, 1/12, g, 2/12, r, 1/12, r , 2/12, d, 1/12, c,

      #       1         1         0         0          1         1
      2/12, -a, 1/12, c, 2/12, r, 1/12, r , 2/12, e, 1/12, g,
      #       0         0         1         1          0         0
      2/12,  r, 1/12, r, 2/12, e, 1/12, e♭, 2/12, r, 1/12, r,
    )
nbAudio("2021/day03puzzle_head.wav")

nbCode:
  import json
  let puzzleHead =
    %*["alto-sax", {"tempo": 234},
      2/12, "a-", 1/12, "c", 2/12, "d", 1/12, "d#", 2/12, "e", 1/12, "g",
      2/12,  "r", 1/12, "g", 2/12, "r", 1/12, "r" , 2/12, "d", 1/12, "c",
      2/12, "a-", 1/12, "c", 2/12, "r", 1/12, "r" , 2/12, "e", 1/12, "g",
      2/12,  "r", 1/12, "r", 2/12, "e", 1/12, "d#", 2/12, "r", 1/12, "r",
    ]
  saveMusic("2021/day03puzzle_head_alt.wav", puzzle_head)
nbAudio("2021/day03puzzle_head_alt.wav")
# json:
# altosax -> alto-sax
# -a -> a-
# dx -> d#
nbCode:
  func getScore(nums: seq[string], denominator=12): JsonNode =
    const arpeggio = @["a-", "c", "d", "d#", "e", "g", "a", "g", "e", "d#", "d", "c"]
    result = %*["alto-sax", {"tempo": 234}]
    var
      beat = true
      i = 0
    for num in nums:
      for digit in num:
        if beat:
          result.add %(2/denominator)
        else:
          result.add %(1/denominator)
        if digit == '1':
          result.add %(arpeggio[i mod 12])
        else:
          result.add %"r"
        inc i
        beat = not beat
  
  saveMusic("2021/day03puzzle_head_longer.wav", getScore(puzzleNums[0 ..< 10]))
  saveMusic("2021/day03puzzle_head_faster.wav", getScore(puzzleNums[0 ..< 20], denominator=24))
nbAudio("2021/day03puzzle_head_longer.wav")
nbAudio("2021/day03puzzle_head_faster.wav")
nbCode:
  saveMusic("2021/day03puzzle.wav", getScore(puzzleNums))
  saveMusic("2021/day03puzzle_faster.wav", getScore(puzzleNums, denominator=24))
nbAudio("2021/day03puzzle.wav")
nbAudio("2021/day03puzzle_faster.wav")

nbText: """
Later I will add more comments, highlights and I have
in mind something special for the "visualization" part (if I get to it).

Stay tuned and enjoy Advent of Nim! 🎄👑
"""

nbSave

