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
Older visualization for [day01](day01.html)
"""
import batteries

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


sort(elfs, ((elfA, elfB) => sum(elfA) - sum(elfB)), order=SortOrder.Descending)

nbJsFromCode(elfs):
  const
    ratio = 100.0
    hElf = 5
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
    createCanvas(800, 2*hElf*len(elfs) + hElf)
    #createCanvas(800, 800)
    background(colDark)
    frameRate(15)
    noStroke()
  draw:
    if idx < elfs.len:
      if idx >= 0: # wait before starting
        showElf(hElf, hElf + (hElf + hElf)*idx, elfs[idx], palettes[idx mod len palettes])
      inc idx
    else:
      # wait a moment
      inc idx
      if idx > elfs.len + idxWait:
        background(colDark)
        idx = -20
nbJsFromCode():
  keyPressed:
    if $key == "s":
      saveGif("day01", 3)
nbSave
