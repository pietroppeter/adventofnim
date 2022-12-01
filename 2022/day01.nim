import nimib, aoc22, p5
let day = Day(
  num: 1,
  title: "Calorie Counting",
  summary: ""
)

nbInit
nbUseP5
nbJsFromCode:
  import p5aoc
nb.darkMode
nbText: day.mdTitle
nbText: """
1. [Part 1](#part1)
2. [Part 2](#part2)
3. [Seen around](#around)
4. [Visualization🌸](#viz)

First day of new year of advent of code, happy to be back here having fun with [nim]
and [nimib] and blogging about it. The idea for this year is to try and make visualization
with [p5nim].

Another thing I will be doing is using [batteries] for importing common stdlib modules.
This is a nice convenience module that was supposed to improve on pattern of doing `include prelude`
but it was [decided not to] put it in stdlib and you can now install it with [nimble].

[decided not to]: https://github.com/nim-lang/Nim/pull/20041
""" & mdRefs
nbCode:
  import batteries
nbText: """### <a name="part1" href="#part1">Part 1</a>
Solving any puzzle you take a lot of micro decision.
Often I like to separate parsing and processing, but in cases like today
it is very convenient to do both at once:
"""
#nbCodeAnd(nbJsFromCode):
nbCode:
  var
    elfs: seq[seq[int]]
    elf: seq[int]
    maxCalories: int

  for line in day.filename.lines:
    if len(line.strip) > 0:
      elf.add parseInt(line)
    else:
      elfs.add elf
      if sum(elf) > maxCalories:
        maxCalories = sum(elf)
      elf = @[]
  # at the end I still need to add last elf
  if len(elf) > 0:
    elfs.add elf
    # and maybe he is the one bringing most calories
    if sum(elf) > maxCalories:
      maxCalories = sum(elf)

  echo maxCalories
gotTheStar
nbText: """### <a name="part2" href="part2">Part 2</a>
Easiest (not most performant) to get top three is to sort:
"""
nbCode:
  sort(elfs, ((elfA, elfB) => sum(elfA) - sum(elfB)), order=SortOrder.Descending)

  echo sum elfs[0..2].mapIt(sum it)
gotTheStar
nbText: """### <a name="around" href="#around">Seen around</a>
Section "seen around" is where I gather interesting stuff seen around about advent of code for today:

- [daily solution megathread](https://www.reddit.com/r/adventofcode/comments/z9ezjb/2022_day_1_solutions/) to post your solution (I did!).
seen a couple of people doing it in Nim
- community [fun event thread](https://www.reddit.com/r/adventofcode/comments/z9he28/advent_of_code_2022_mistiltoe_elfucation/)
(I will have to participate with p5nim project)
- unofficial participant [survey](https://www.reddit.com/r/adventofcode/comments/z9eoer/unofficial_aoc_2022_participant_survey/),
do it and mention you are using Nim! (I did complete the survey)
- a nice [visualization](https://www.reddit.com/r/adventofcode/comments/z9kk1m/2022_day_1_adding_up_the_calories/)
(apparently done in PyCairo)
- eric wastl aka r/topaz aka creator of adventofcode is worried about user agents
and has [some advice to give](https://www.reddit.com/r/adventofcode/comments/z9dhtd/please_include_your_contact_info_in_the_useragent/)
- this year we will have lots of AI generated visualizations here is [one](https://www.reddit.com/r/adventofcode/comments/z9g0i0/ai_imagine_advent_of_code_2022_day_1/)
and [another (with demons)](https://www.reddit.com/r/adventofcode/comments/z9iz9t/i_may_have_mistyped_santa/)
- I did also post [my visualization](https://www.reddit.com/r/adventofcode/comments/za0xyr/2022_day_1nim_visualization_with_nim_bindings_to/)
on the subreddit
- this year are back the most beatiful nim solutions, the ones by [MichalMarsalek](https://github.com/MichalMarsalek/Advent-of-code/blob/master/2022/Nim/day1.nim)
- PMunch is streaming again this year! you can watch it [here](https://www.twitch.tv/videos/1667530842)
(starts around 3:40, I am listening to it now)
- someone is solving aoc with [github copilot](https://twitter.com/TheZachMueller/status/1598342197816004608)
(the idea comes from a nice discord of data professionals emigrated from twitter, you can find the prompt in the #advent-of-code chat there [invite](https://discord.gg/jW52MxX5))
- will Peter Norvig do advent of code this year? has not started committing yet, if he does
it will appear in his [pytudes repo](https://github.com/norvig/pytudes)
- Jari Komppa last year did a great series of gifs for solutions, he is going
at it [this year](https://twitter.com/Sol_HSA/status/1598192914781597696?s=20&t=NzB5qlmO7tj5HRiSNPGdeQ) too
"""
nbText: """### Visualization

Let's look at total food and number of elfs before visualizing.
"""
nbCode:
  echo sum elfs.mapIt(sum it)
  echo len(elfs)

template myJsWithCaptures(body: untyped) =
  nbJsFromCode(elfs):
    body

nbText: """
Here is a very simple visualization:
  - plot a rectangle for every elf, with length proportional to the food
  - every piece of food is colored with a color extracted from a palette
  - list of palettes is taken from [takawo]
  - I also wait a moment before starting and wait also at the end

[takawo]: https://openprocessing.org/sketch/1751402
"""
nbCodeDisplay(myJsWithCaptures):
  const
    ratio = 100.0
    hElf = 2
    idxWait = 100
  var idx = -20

  proc showElf(x, y: float, food: seq[int], colors: seq[string]) =
    push()
    translate(x, y)
    for i, f in food:
      fill(colors[i mod colors.len])
      rect(0, 0, f / ratio, hElf)
      translate(f / ratio, 0)
    pop()

  echo elfs
  setup:
    createCanvas(800, hElf*len(elfs))
    #createCanvas(800, 800)
    background(colDark)
    frameRate(50)
    noStroke()
  draw:
    if idx < elfs.len:
      if idx >= 0: # wait before starting
        showElf(0, hElf*idx, elfs[idx], palettes[idx mod len palettes])
      inc idx
    else:
      # wait a moment
      inc idx
      if idx > elfs.len + idxWait:
        background(colDark)
        idx = -60
nbRawHtml: "<a name=\"viz\"></a>"
nbJsFromCode():
  keyPressed:
    if $key == "s":
      saveGif("day01", 3)
nbText: "for an older version of this visualization go [here](day01_viz1.html)"
nbSave
#[
this does not work, issue with capturing variables?

nbJsFromCode(elfs):
  echo elfs
- [ ] investigate and produce minimial repr example (and submit issue to nimib)

another issue: SIGSEGV: Illegal storage access. (Attempt to read from nil?)

-> this might be a bug in orc (in my current nim 1.6.6)! if I remove orc it works!

# saving gif does not work
]# 