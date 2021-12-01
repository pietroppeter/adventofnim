import nimib, animu, nimoji

nbInit(theme=useAdventOfNim)
nbText: """## 2021, day 1: 

Another year of Advent of Nim :christmas_tree::crown:!

This year I would like to try and use cool nim libraries
for visualization and similar stuff.
I will most likely be able to keep up only for a few days, but let's see.

But let's get to the first problem.
As usual we have a sequence of integers as input.

What is new this year is that,
[thanks to 1.6](https://nim-lang.org/blog/2021/10/19/version-160-released.html)
we can use `toSeq` with method call syntax
""".emojize

nbCode:
  let input: seq[int] = "2021/input01.txt".lines.toSeq.map(parseInt)
  echo input.len
  echo input[0 .. 10]
  echo input[^10 .. ^1]

nbCode:
  func countIncrease(s: seq[int]): int =
    for i in 1 .. s.high:
      if s[i] > s[i - 1]:
        inc result

  echo countIncrease(input)

gotTheStar

nbCode:
  func window(s: seq[int], size=3): seq[int] =
    assert s.len >= size
    var sum = s[0 ..< size].sum
    result.add sum
    for i in size .. s.high:
      sum = sum - s[i - size] + s[i]
      result.add sum
  
  echo input[0 ..< 10]
  echo input[0 ..< 10].window
  echo input.window.countIncrease

gotTheStar
nbSave