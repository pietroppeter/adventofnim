import nimib, aoc22, p5
let day = Day(
  num: 1,
  title: "Calorie Counting",
  summary: ""
)

nbInit
nbUseP5
nb.darkMode
nbText: day.mdTitle
nbText: """
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

"""
#nbCodeDisplay(nbJsFromCode):
nbJsFromCode:
  #echo elfs
  setup:
    createCanvas(300, 300)
  draw:
    rect(10, 10, 30, 30)
nbSave
#[
this does not work, issue with capturing variables?

nbJsFromCode(elfs):
  echo elfs
- [ ] investigate and produce minimial repr example (and submit issue to nimib)

another issue: SIGSEGV: Illegal storage access. (Attempt to read from nil?)

]# 