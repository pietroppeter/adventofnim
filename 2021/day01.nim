import nimib, animu, nimoji

nbInit(theme=useAdventOfNim)
nbText: """## 2021, day 1: [Sonar Sweep](https://adventofcode.com/2021/day/1) ⛴️🔈

Another year of [Advent of Nim](https://forum.nim-lang.org/t/8657) :christmas_tree::crown:!

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
there is a simpler way to compute part 2 that also reveals that _the "window" approach
does not really denoise the signal_. Since two successive windows of 3 depths have 2 overlapping
depth, to check if there is an increase we only need to check first and last depth:
"""

nbCode:
  func countIncrease2(s: seq[int], window=3): int =
    for i in 0 ..< (s.len - window):
      if s[i + window] > s[i]:
        inc result

  echo input.countIncrease2

doAssert input.countIncrease2 == 1608
# note that countIncrease2 is equivalent to countIncrease(..., window=1)

nbText: """### Visualization

I will use the excellent [ggplotnim](https://github.com/Vindaar/ggplotnim)
to plot the depth profile and the dataframe library [datamancer](https://github.com/SciNim/Datamancer)
(implictly imported through ggplotnim) to manage the data.
Thanks to [Vindaar](https://github.com/Vindaar) for help in this section
"""

nbCode:
  import ggplotnim 
  var df = seqsToDf({"depth": input})  # toDf(input): new column will be named input
  df["x"] = collect:
    for i in 1 .. input.len:
      i
  echo df
  let
    dark = parseHex("202b38")
    gold = parseHex("ffff66")
  ggplot(df, aes(x="x", y="depth")) + scale_y_reverse() +
    geom_line(color=some(gold)) + theme_void(color=dark) +
    ggsave("2021/01_depths.png")

nbImage("2021/01_depths.png")

nbText: """
Note:
  - we use `seqsToDf` and a table constructor in order to give a new name to input
  - we built (using sugar's collect) a dummy x axis in order to use it in the plots
  - we reverse y scale to give the idea of increasing depth of sea bottom
  - we use a gold line and same background as that of the page, removing all axis
  - colors come from [chroma](https://github.com/treeform/chroma)

Interesting also to plot the depth differences
(and its average, which we can expect to be close to 4):
"""

nbCode:
  df["diff_depth"] = collect:
    for i in 0 .. input.high:
      if i == 0:
        0
      else:
        input[i] - input[i-1]
  let mean_diff_depth = mean(df["diff_depth"].toTensor(float))
  dump mean_diff_depth
  echo df
  let
    green = parseHex("009900")
    red = parseHtmlName("red")
  let
    font_aoc = Font(
      family: "sans-serif",
      size: 12.0,
      bold: false,
      slant: fsNormal,
      color: green,  # only change with respect to default
      alignKind: taCenter
    )
    theme_aoc = Theme(
      canvasColor: some(dark),
      plotBackgroundColor: some(dark),
      gridLineColor: some(green),
      labelFont: some(font_aoc),
      tickLabelFont: some(font_aoc),
      hideTicks: some(true)  # I cannot find where to set them as green, so I hide them
    )
  ggplot(df, aes(x="x", y="diff_depth")) +
    geom_line(color=some(gold)) + theme_aoc +
    geom_linerange(aes = aes(y = mean_diff_depth, xMin = 0, xMax = 2000), color=some(red)) +
    ggsave("2021/01_relative_depth.png")

nbImage("2021/01_relative_depth.png")

nbText: """
Note:
  * to compute the mean we use `toTensor` and we convert to float (otherwise the result will be an `int`)
  * we create a custom "aoc" theme setting appropriately colors
  * we are using `geom_linerange` to plot the horizontal line since `geom_hline` is not (yet) implemented

### highlights from subreddit

Among the different stuff that is published in advent of code
[subreddit](https://www.reddit.com/r/adventofcode/)
I found interesting:

  - a site that allows to [search all solutions](https://aocweb.yulrizka.com/?year=2021&day=1&language=Nim)
  posted in the solution megathread by programming language ([announcement](https://www.reddit.com/r/adventofcode/comments/r6cmn1/aocweb_a_website_that_collects_solutions_from_the/))
  - a [visualization](https://www.reddit.com/r/adventofcode/comments/r6asn2/2021_day_1_part_1well_its_a_game_turing_complete/) of a solution built with
  [Turing Complete](https://store.steampowered.com/app/1444480/Turing_Complete/),
  a game coded in Nim
"""

#[
  add section of highlights from subreddit

  - new theme: adventure time
  - site with all solutions
  - turing complete solution
  - deep water visualization
  - ...
]#
nbSave