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
First day of new year of advent of code, happy to be back here having fun with [nim]
and [nimib] and blogging about it. The idea for this year is to try and make visualization
with [p5nim].

👇[shortcut for visualization](#viz)

Another thing I will be doing is using [batteries] for importing common stdlib modules.
This is a nice convenience module that was supposed to improve on pattern of doing `include prelude`
but it was [decided not to] put it in stdlib and you can now install it with [nimble].

[decided not to]: https://github.com/nim-lang/Nim/pull/20041
""" & mdRefs
nbCode:
  import batteries
nbText: """### Part 1
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
nbText: """### Part 2
Easiest (not most performant) to get top three is to sort:
"""
nbCode:
  sort(elfs, ((elfA, elfB) => sum(elfA) - sum(elfB)), order=SortOrder.Descending)

  echo sum elfs[0..2].mapIt(sum it)
gotTheStar
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