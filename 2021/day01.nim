import nimib, animu, nimoji

nbInit(theme=useAdventOfNim)
nbText: """## 2021, day 1: [Sonar Sweep](https://adventofcode.com/2021/day/1) ⛴️🔈

Another year of Advent of Nim :christmas_tree::crown:!

_This year I would like to try and use cool nim libraries
for visualization_ and similar stuff.
I will most likely be able to keep up only for a few days, but let's see.

But let's get to the first problem.
As usual we have a sequence of integers as input.

What is new this year is that,
[thanks to 1.6](https://nim-lang.org/blog/2021/10/19/version-160-released.html)
we can use `toSeq` with method call syntax!
""".emojize

nbCode:
  let input: seq[int] = "2021/input01.txt".lines.toSeq.map(parseInt)
  echo input.len
  echo input[0 .. 10]
  echo input[^10 .. ^1]

nbText: """### Part 1

> As the submarine drops below the surface of the ocean, it automatically performs a sonar sweep of the nearby sea floor. On a small screen, the sonar sweep report (your puzzle input) appears: each line is a measurement of the sea floor depth as the sweep looks further and further away from the submarine.
> 
> For example, suppose you had the following report:
"""

nbCode:
  let report = """
199
200
208
210
200
207
240
269
260
263"""

nbText: """
> This report indicates that, scanning outward from the submarine, the sonar sweep found depths of 199, 200, 208, 210, and so on.
> 
> The first order of business is to figure out how quickly the depth increases, ...
>
> To do this, count the _number of times a depth measurement increases_ from the previous measurement
>
> ... In this example, there are 7 measurements that are larger than the previous measurement.

The solution for part1 (as expected) is pretty straightforward.
Just make sure you start from index 1:
"""

nbCode:
  func countIncrease(s: seq[int]): int =
    for i in 1 .. s.high:
      if s[i] > s[i - 1]:
        inc result

  let testInput = report.splitLines.toSeq.map(parseInt)
  doAssert testInput.countIncrease == 7
  echo countIncrease(input)

doAssert countIncrease(input) == 1557

gotTheStar

nbText: """### Part 2

> Considering every single measurement isn't as useful as you expected: there's just too much noise in the data.
>
> Instead, consider _sums of a three-measurement sliding window_.
>
> ... Your goal now is to count _the number of times the sum of measurements in this sliding window increases_ from the previous sum.
>
> ... In [test] example, there are 5 sums that are larger than the previous sum.

let's create a function that copmutes the window function of a sequence,
then we will apply previous function to the result.
"""
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

nbCode:
  doAssert testInput.window.countIncrease == 5
  echo input.window.countIncrease

gotTheStar
doAssert input.window.countIncrease == 1608

nbText: """### Optimizing part 2

As hinted by [narimiran](https://github.com/narimiran) in our nim-aoc discord chat,
there is a simpler way to compute part 2 that also reveals that the "window" approach
does not really denoise the signal. Since two successive windows of 3 depths have 2 overlapping
depth, to check if there is an increase we only need to check first and last depth:
"""

nbCode:
  func countIncrease2(s: seq[int], window=3): int =
    for i in 0 ..< (s.len - window):
      if s[i + window] > s[i]:
        inc result

  echo input.countIncrease2

#doAssert input.countIncrease2 == 1608

nbText: """### Visualization

I will use the excellent [ggplotnim](https://github.com/Vindaar/ggplotnim)
to plot the depth profile.

_(not yet able to have the generation of image work :()_
"""

nbCode:
  import ggplotnim 
  let df = toDf(input)
  echo df
  # ggplot(df, aes("input")) + geom_histogram() + ggsave("2021/01depths.png")

nbImage("2021/01depths.png")
nbSave