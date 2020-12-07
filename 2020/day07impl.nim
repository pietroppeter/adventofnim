import nimib, animu, sugar

nbInit

nbText: "# --- Day 7: Handy Haversacks ---"

# I should recover in nimib the simple toc example, it is indeed useful.
nbText: """## General strategy

The solution will be in 5 parts:

  1. colors: I will use global variables
  2. parse a single rule: manual parsing (no regex, no npeg - tried but did not succeed at first try)
  3. reversing the rules: while parsing the rules I will also create the mapping
     from a color to its direct containers.
  4. solve part 1: recursive
  5. solve part 2: recursive 
"""

nbText: """## 1. Colors
I am going to use two global variables names and colors. Here are the functions needed for them.

I do not know why I set `Color = distinct int`, it is probably unnecessary and just complicates stuff.
"""
nbCode:
  type
    Color = distinct int ## why not use a distinct type to make our life a little bit messier?
    Names = seq[string]
    Colors = OrderedTable[string, Color]
  var
    names: Names
    colors: Colors

  proc addColor(name: string) =
    if name not_in names:
      names.add name
      let i = names.len - 1
      colors[name] = i.Color

  proc `$`(c: Color): string = names[c.int]  ## I take advantage that names is global
  proc toColor(s: string): Color = colors[s]

  template resetGlobals =
    ## to reset the globals (after solving for the example)
    names = @[]
    colors = initOrderedTable[string, Color]()
    addColor "shiny gold"  ## always will be the 0.Color

  dump 0.Color
  dump toColor("shiny gold")
  dump names

  ## later on I will put Color in a table. You need this or you will get a rather cryptic error message
  proc `==`(a,b: Color): bool {.borrow.}

nbText: """## What is a Rule and how to parse it
note that parseRule does use the globals `names` and `colors`.

I did try first with npeg, but I am still missing stuff,
so for the moment I will keep to with manual parsing (`parseUntil` for the win!)."""
nbCode:
  type
    Rule = tuple[col: Color, cons: Contents]
    Contents = seq[tuple[qty: int, col: Color]]

  proc parseRule(text: string): Rule =
    var
      col: string
      cons: string
      qty: int
    let
      i = parseUntil(text, col, " bags")
      j = " bags contain ".len
    discard parseUntil(text, cons, ".", start=i+j)
    addColor col
    result.col = col.toColor
    for con in cons.split(", "):
      if con == "no other bags":
        break
      let
        i = parseInt(con, qty)
      discard parseUntil(con, col, " bag", start=i+1)
      addColor col
      result.cons.add (qty, col.toColor)

  echo parseRule "light red bags contain 1 bright white bag, 2 muted yellow bags."
  echo parseRule "bright white bags contain 1 shiny gold bag."
  echo parseRule "faded blue bags contain no other bags."
  echo names
  echo colors

nbText: """## reversing the rules
while parsing the rules I will also create the mapping
from a color to its direct containers.

I do not know why I create a `PuzzleInput` type but I like how it looks in proc signatures.

The parsing is finally applied to the example.

I will reuse the variables `rs` and `dc`."""
nbCode:
  type
    PuzzleInput = string
    Rules = OrderedTable[Color, Contents]
    DirContainers = OrderedTable[Color, seq[Color]]

  proc parse(p: PuzzleInput): (Rules, DirContainers) =
    var
      r: Rule
      rs = initOrderedTable[Color, Contents]()
      dc = initOrderedTable[Color, seq[Color]]()
    for line in p.splitLines:
      r = parseRule line
      rs[r.col] = r.cons
      for con in r.cons:
        if con.col not_in dc:
          dc[con.col] = @[r.col]
        elif con.col not_in dc[con.col]:
          dc[con.col].add r.col
    for col in colors.keys:
      if col.toColor not_in dc:
        dc[col.toColor] = newSeq[Color]()
    return (rs, dc)

  let example = """light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.""".PuzzleInput

  var
    (rs, dc) = parse example
  echo "Rules:"
  for k, v in rs:
    echo k, ": ", v
  echo "DirContainers:"
  for k, v in dc:
    echo k, ": ", v

nbText: """## Solve part 1

with a short and careful recursion (note I keep variable `ac` in each recursive call).

output for real input will come later (so that I reset once the globals)"""
nbCode:
  type AllContainers = OrderedSet[Color]

  proc allContainers(c: Color, dc: DirContainers, ac: var AllContainers) =
    for cx in dc[c]:
      if cx in ac:  ## not sure if I need this, but for sure it is a protection against infinite recursion
        ac.incl cx
      else:
        ac.incl cx
        allContainers(cx, dc, ac)

  var ac: AllContainers
  (0.Color).allContainers(dc, ac)
  echo ac

nbText: """## Solve part2

Showing first solving for the example.

I like the indentation trick I used to debug the solution, so I leave it visible."""
nbCode:
  var ind = 0

  proc reqBags(c: Color, rs: Rules): int =
    ind += 2
    ##echo ("color: " & $c).indent(ind)
    ##echo ("contents: " & $(rs[c])).indent(ind)
    for con in rs[c]:
      result += con.qty
      result += con.qty*(reqBags(con.col, rs))
    ##echo ("result: " & $result).indent(ind)
    ind -= 2

  echo "reqBags(example): ", (0.Color).reqBags(rs)

nbText: "## Getting the stars\nSolutions for my puzzle input"
nbCode:
  let input = "2020/input07.txt".readFile.PuzzleInput
  resetGlobals

  ac = initOrderedSet[Color]() ## I need to reset this one too.
  (rs, dc) = parse input
  (0.Color).allContainers(dc, ac)
  echo "part1: ", ac.len
  echo "part2: ", (0.Color).reqBags(rs)

gotTheStar
gotTheStar