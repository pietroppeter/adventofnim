import animu, nimib

nbInit(theme=useAdventOfNim)
nb.useLatex
nbText: """## Day 13: Transparent Origami

Last days I got lazy and forgot to blogpost after solving the puzzle.
Today I will _write the blogpost while I solve the puzzle_.

### Part 1

Let's first understand how to fold, we will implement parse stuff later.

To fold a dot $(x, y)$ along $y=7$, the $x$ coordinate will not change
while the $y$ coordinate will change only if bigger than $7$
and it will be below $7$ by the same amount that it was above $7$:

$$7 - (y - 7) = 2*7 - y$$.

Below I will make a single `foldAlong` that will work both for $x$ and $y$
"""

nbCode:
  type Dot = tuple[x, y: int]

  func foldAlong(d: Dot, y = 0, x = 0): Dot =
    if y > 0 and d.y > y:
      (d.x, 2*y - d.y)
    elif x > 0 and d.x > x:
      (2*x - d.x, d.y)
    else:
      d

  echo foldAlong(d=(2, 14), y=7)

nbText: """
And now we fold a sequence of point, making sure at the end that we
remove duplicates. I could use `deduplicate` from `std / sequtils`
but since it does not do anything fancy, I implement it inside here
"""
nbCode:
  func foldAlong(dots: seq[Dot], y = 0, x = 0): seq[Dot] =
    var e: Dot
    for d in dots:
      e = foldAlong(d, y = y, x = x)
      if e not_in result:
        result.add e

  echo foldAlong(dots = @[(3, 0), (5, 0)], x = 4)      

nbText: """
Now it make sense to parse stuff. When the input is made of two parts
I prefer to use copy and paste and split the parts manually.
The first instruction I can also parse manually.
"""
nbCode:
  func parse(text: string): seq[Dot] =
    for line in text.splitLines:
      let l = line.strip.split(',')
      result.add (parseInt(l[0]), parseInt(l[1]))

  let testInput = """
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0"""

  let testDots = parse testInput
  dump testDots.len
  echo testDots[0 ..< 3], " ... ", testDots[^3 .. ^1]

  dump foldAlong(testDots, y=7).len

nbText: "Test input ok, let's proceed for puzzle input"
nbCode:
  let
    puzzleInput = readFile("2021/input13.txt")
    puzzleDots = parse puzzleInput
  dump puzzleDots.len
  echo puzzleDots[0 ..< 3], " ... ", puzzleDots[^3 .. ^1]
  dump foldAlong(puzzleDots, x=655).len

gotTheStar

nbText: """### Part 2
As expected, part 2 will ask me to complete folding and visualize the code.

Since the folding instructions are not many, a manual fix and a template will do:
"""
nbCode:
  var dots: seq[Dot]

  template fold_along(x=0, y=0) =
    dots = foldAlong(dots, y, x)

  template foldTest =
    dots = testDots
    fold_along(y=7)
    fold_along(x=5)

  template foldPuzzle =
    dots = puzzleDots
    fold_along(x=655)
    fold_along(y=447)
    fold_along(x=327)
    fold_along(y=223)
    fold_along(x=163)
    fold_along(y=111)
    fold_along(x=81)
    fold_along(y=55)
    fold_along(x=40)
    fold_along(y=27)
    fold_along(y=13)
    fold_along(y=6)
  
  foldTest
  echo dots.len
  echo dots
nbText: """
to visualize we will first sort to have smallest y first (same y will start with smallest x).
Note that sorting could also be a performance hack: we could remove the if check in foldAlong
and deduplicate by checking `!=` with previous (as `deduplicate` in `sequtils` does).

I remember that sorting requires a compare function that gives me a int but I can
never remember if positive means first bigger than second (spoiler: yes) or the other way around
(this probably should an info that belongs to
[sorting docs](https://nim-lang.org/docs/algorithm.html#%2A%2Cint%2CSortOrder), you can find it
in [system.cmp docs](https://nim-lang.org/docs/system.html#cmp%2CT%2CT), should make a PR)
"""
nbCode:
  func cmpAlongY(d, e: Dot): int =
    result = (d.y - e.y)
    if result == 0:
      result = (d.x - e.x)

  dump cmpAlongY((4, 10), (6, 8))
  dump cmpAlongY((4, 8), (6, 8))

  func sortedAlongY(dots: seq[Dot]): seq[Dot] =
    sorted(dots, cmpAlongY)
  
  dump testDots.sortedAlongY[0 .. 5]
nbText: """and finally it is showtime!

The following `show` function will work correctly only
if input is sorted along Y axis and yMax and xMax get the whole area
"""
nbCode:
  func show(dots: seq[Dot], yMax=7, xMax=50): string =
    var i = 0
    for y in 0 .. yMax:
      for x in 0 .. xMax:
        if i < dots.len and dots[i] == (x, y):
          result.add '#'
          inc i
        else:
          result.add '.'
      result.add '\n'

  # dots currently is results of folding testDots
  echo show(dots.sortedAlongY)

nbText: "looks good, let's go with the puzzle:"
nbCode:
  foldPuzzle
  echo show(dots.sortedAlongY) #AHGCPGAU
gotTheStar
nbSave
