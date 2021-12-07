import animu, nimib
nbInit(theme=useAdventOfNim)
nb.useLatex
#[
todo: add in nimib a `nbHeader "## Day 6: Lanternfish 🎣🔆"
that creats a header with link name day-6-lanternfish
and could add a headers section in context with...
well I am just picking a different api for the toc example of the cheatsheet...
]# 
nbText: """## Day 6: Lanternfish 🎣🔆

Today is the classical case of: "simple (brute force) approach
will work for part1 but it will not work for part2. Also it
is the kind of the day where I tend to try and derive mathematical
properties on some functions and get lost along the way
(like [last year](../2020/day10hints.html)).

This year these days I have some catch up to do
(still have to post day 4 and 5, lots of viz missing)
so I will go with the first stuff that comes to mind,
the end result is not great so you might want to skip
to the end where I give links to better solutions by advent-of-nim-mers.

### Part 1

If you are still here, well,
I grew fond of the include trick that I used in [day02](day02.html)
that I am using it even when there is totally uncalled for.
I just have to modify slightly the input: `let puzzleInput = @[<input>]`
and actually I do not even need to give it a nim extension, you can include
a file with any extension:
"""
nbCode:
  include "2021/input06.txt"
  echo puzzleInput.len
  echo puzzleInput[0 ..< 10], " ... ", puzzleInput[^10 .. ^1]
nbText: """
We are giving a list of numbers (all between 1 and 5) and
they represent "ages" of fishes that evolve with following rules:
  - age decrease by 1 every time step
  - after reaching 0 a fish cycles back to age 6 and spawns a new fish of age 8 (added at the end of the list)
the question for part 1 is:

> _How many lanternfish would there be after 80 days?_

First observation is the fact that there is no interaction between fishes,
so I can concentrate on the evolution of a single fish.
I started thinking about properites of a couple of functions $f, F$:
  1. $f(a, s, t)$: number of generated fish at time $t from a fish of age a at time s
  2. $f(a, s, t) = f(a, 0, t - s)$: I should not really care about $s$.
  3. $f(a + b, s, t) = f(a, s, t - b)$
  4. $F(a_1, ..., a_N, t)$: tot number of gen fish at time $t$ from fishes of "ages" $a_1, ... a_N$ at time 0
    (I need to compute $F(\mathrm{input}, 80)$)
  5. $F(a_1, ..., a_N, t) = f(a1, 0, t) + ... + f(aN, 0, t)$
    (this is the observation above that fish evolutions are independent)
  6. if $b_1, ... b_5$ are numbers of fishes with ages equal to $1, ..., 5$, then
    $F(a_1, ..., a_N, t) = b_1 \cdot f(1, 0, t) + ... + b_5 \cdot f(5, 0, t)$
  7. using rule 3 above I only need to compute $f(1, 0, t - i)$ for $i \in 1 .. 5$

In practice I need only to compute the evolution of `@[1]`.
The basic function that ticks evolution at every time step:
"""
nbCode:
  func tick(school: seq[int]): seq[int] =
    result = newSeqWith(len=school.len): -1
    for i, a in school:
      if a == 0:
        result[i] = 6
        result.add 8
      else:
        result[i] = a - 1
nbText: "and now solution for part 1"
nbCode:
  func part1(input: seq[int], targetTime=80): (int, seq[int]) =
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
  dump part1(puzzleInput)[0]

gotTheStar

nbText: """### Part 2

And indeed we are asked to do the compute the same function
but over a horizon of 256 days. I tried expecting no result
and indeed the above approach does not give me an answer in
a reasonable time not even for test input.

Now the approach of counts in part1 was very promising
and I could have gotten a simple solution out of it
(see below of examples) but somehow I decided seeing 256
that I would chunk the problem in 16 chunks of duration 16
(making things more complicated than they should be).

So I set myself to compute:
  - $g(i, t) = [g_0(i, t), ... g_8(i, t)]$
  - where $g(i, t)$ is a multi valued function that tells me
    how many fishes of age $j$ I will have at time $t$
    starting from a single fish of age $i$ ($g_j(i, t)$)
"""
nbCode:
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

nbText: "and here is the function that puts together the chunks:"
nbCode:
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

gotTheStar
nbText: """### Highlights

- see how simple could have been the solution if I went with the count approach
  looking at [pmunch solution for part 2](https://github.com/PMunch/aoc2021/blob/master/day06/part2.nim).
  Do not forget that he also [streams](https://www.youtube.com/playlist?list=PL9Yd0XwsGAqyd_lKcHm3f_nlE8vMdacV0) his way about the solutions
  which is a great way to see how someone reasons starting from scratch!
- another approach for this would have been a recursive, memoized approach
  like the one beautifully and concisely expressed by [MichalMarsalek](https://github.com/MichalMarsalek/Advent-of-code/blob/master/2021/Nim/day6.nim)
- Michal got [nerd sniped] by this and did a [part 3] and a [part 4]
  with increasingly higher target times that requires more sophisticated behaviours
  and even involve a nice little cryptographic primitive called the [LSFR] (Linear-feedback shift register).
  It will take me a moment to absorb all that!
- a [nice animation] of the count of fishes by age on a log axis;
  you can kind of see the exponential growth since it seems to grow linearly
  on the log axis.
- love the [ascii fish] as cursor writing the solution and what's the name of
  the thing where you change indentation of code to make it look like
  sort of image (in this case a tree branching down)?

[ascii fish]: https://www.reddit.com/r/adventofcode/comments/rall1t/2021_day_6_the_lanternfish_solved_it_for_me/
[nice animation]: https://www.reddit.com/r/adventofcode/comments/ra7gl8/2021_day_6_number_of_lanternfish_of_each_age_per/
[nerd sniped]: https://xkcd.com/356/
[part 3]: https://www.reddit.com/r/adventofcode/comments/ra3f5i/2021_day_6_part_3_day_googol/
[part 4]: https://www.reddit.com/r/adventofcode/comments/ra88up/2021_day_6_part_4_day_googolplex/
[LSFR]: https://en.wikipedia.org/wiki/Linear-feedback_shift_register

### Visualization

I do not really know when I will have time do that (if ever), but I would
love to try and make a little [nico] game with lanternfishes popping
around and your submarine trying to evoke whales to kill them...

[nico]: https://github.com/ftsf/nico
"""
nbSave