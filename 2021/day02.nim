import nimib, animu

nbInit(theme=useAdventOfNim)
nbText: """## Day 2: [Dive!](https://adventofcode.com/2021/day/2) 🚣‍♂️

Let's start from the _title_. Last year titles were all two words, with today's title
(Dive!) we break this recent tradition (in the past there were longer titles).
Were there other days with _single word_ titles in the past? Is there a list
of titles used? The best I could come up with is
[miran's repo collection](https://github.com/narimiran/AdventOfCode2020),
but it seems he is also breaking tradition this year and not adding the title
to his usual nice table.

Today the problem involved _parsing_, as we would all expect.
But do we really need to parse stuff?
The [small bible for parsing in Nim for Advent of Code](https://narimiran.github.io/2021/01/11/nim-parsing.html) is again from miran.
You would think he would have covered all methods for parsing,
but in fact today I discovered there are two more:

  - one is [scanTuple](https://nim-lang.org/docs/strscans.html#scanTuple.m%2Cuntyped%2Cstatic%5Bstring%5D%2Cvarargs%5Buntyped%5D),
    which is `scanf` without the need of predeclaring the variables.
    Why does miran's bible misses on that?
    does he have beef with [beef](https://github.com/nim-lang/Nim/pull/16300)?
    Well, the reason is more likely to be that it was implemented after the post was written
    and in fact it is another new shiny thing from 1.6, a hidden gem that
    was not even mentioned in the [release notes](https://nim-lang.org/blog/2021/10/19/version-160-released.html)
  - the second apocriphal way of doing parsing is even more _magic_ since
    _you do not actually do the parsing_ and let a _good old friend_ do it.
    It dawned on me during breakfast while I was _looking at the puzzle input_
    and thinking about _an implementation_ 🤯!

What is it? follow along to find out!

### Part 1

> [...] the submarine can take a series of commands like forward 1, down 2, or up 3:
> 
> - forward X increases the horizontal position by X units.
> - down X _increases_ the depth by X units.
> - up X _decreases_ the depth by X units.
> Note that since you're on a submarine, down and up affect your _depth_, and so they have the opposite result of what you might expect.
> 
> The submarine seems to already have a planned course (your puzzle input). You should probably figure out where it's going. For example:
"""
nbCode:
  template testInput =
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2

nbText: """
> Your horizontal position and depth both start at 0. 
> 
> [...] After following these instructions, you would have a horizontal position of 15 and a depth of 10. (Multiplying these together produces 150.)
> 
> Calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?

Can you see now what is the magic trick and the old friend?
Did the _template_ above give it away?
Well, the trick is that the old friend that will do that parsing is
Nim compiler and I will just have to `include` the input (which I have saved in a nim file):
"""
nbCode:
  var
    solution: int
  template solve = solution = pos.x*pos.d

nbCodeInBlock:
  var pos: tuple[x, d: int]
  template down(n: int) = pos.d += n
  template up(n: int) = pos.d -= n
  template forward(n: int) = pos.x += n
  template reset = pos = (0, 0)
  testInput
  solve
  assert solution == 150
  # real input
  reset
  include input02
  solve
  echo solution

gotTheStar

assert solution == 2322630

nbText: """### Part 2

> Based on your calculations, the planned course doesn't seem to make any sense. You find the submarine manual and discover that the process is actually slightly more complicated.
> 
> In addition to horizontal position and depth, you'll also need to track a third value, _aim_, which also starts at 0. The commands also mean something entirely different than you first thought:
> 
> - down X _increases_ your aim by X units.
> - up X _decreases_ your aim by X units.
> - forward X does two things:
>   - It increases your horizontal position by X units.
>   - It increases your depth by your aim _multiplied by_ X.
>
> [...] Now, the above example [...] you would have a horizontal position of 15 and a depth of 60. (Multiplying these produces _900_.)
> 
> Using this new interpretation of the commands, calculate the horizontal position and depth you would have after following the planned course. _What do you get if you multiply your final horizontal position by your final depth?_
"""
nbCodeInBlock:
  var pos: tuple[x, d, a: int]
  template down(n: int) = pos.a += n
  template up(n: int) = pos.a -= n
  template forward(n: int) =
    pos.x += n
    pos.d += pos.a*n
  template reset = pos = (0, 0, 0)
  testInput
  solve
  assert solution == 900
  reset
  include input02
  solve
  echo solution

gotTheStar

assert solution == 2105273490

nbText: """
Note that in nimib I can limit the scope of the code to a single block
with `nbCodeInBlock`, which is what I am doing here to be able to redefine same stuff
for part 2 (but `solution`, `solve` and `testInput` are in a `nbCode` block
so that they can be available for both parts).

### highlights of the day

- as I suspect I was not the only to have thought about the `include` parsing trick,
  checkout [MichalMarsalek repo](https://github.com/MichalMarsalek/Advent-of-code/tree/master/2021/Nim)
  which has also a great setup specific for aoc.
- [pmunch](https://github.com/PMunch/aoc2021) shared his repo and is back streaming for another year! 🥳

from [subreddit](https://www.reddit.com/r/adventofcode/):

- a [fake day 3](https://www.reddit.com/r/adventofcode/comments/r77mkv/these_problems_are_harder_than_i_remembered/) about _wreath numbers_
- a crazy [Unreal engine rendering of first day](https://www.reddit.com/r/adventofcode/comments/r71sss/2021_day_1_ue4_short_intro_video/)
- a [solution in Piet](https://www.reddit.com/r/adventofcode/comments/r6v23p/day_1_part_1_a_solution_in_piet_a_language_where/),
  an esoteric language where programs look like abstract paintings

I would also have wanted to do a visualization with [nanim](https://github.com/EriKWDev/nanim)
but did not have yet time, maybe I will add it later, stay tuned and happy Advent of Nim! 🎄👑 
"""

nbSave
