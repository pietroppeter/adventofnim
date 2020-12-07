import tables, parseutils, strutils

type
  Color = distinct int
  Names = seq[string]
  Colors = OrderedTable[string, Color]
var
  names: Names
  colors: Colors

names.add "shiny gold"
colors[names[0]] = 0.Color

proc addColor(name: string) =
  if name not_in names:
    names.add name
    let i = names.len - 1
    colors[name] = i.Color

addColor "shiny gold"

proc `$`(c: Color): string = names[c.int]  ## I take advantage that names is global
proc toColor(s: string): Color = colors[s]

echo 0.Color
echo toColor("shiny gold")

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
    k = parseUntil(text, cons, ".", start=i+j)
  addColor col
  result.col = col.toColor
  for con in cons.split(", "):
    if con == "no other bags":
      break # same as break
    let
      i = parseInt(con, qty)
      j = parseUntil(con, col, " bag", start=i+1)
    addColor col
    result.cons.add (qty, col.toColor)

echo  parseRule "light red bags contain 1 bright white bag, 2 muted yellow bags."
echo  parseRule "bright white bags contain 1 shiny gold bag."
echo  parseRule "faded blue bags contain no other bags."
echo names
echo colors

type
  PuzzleInput = string
  Rules = OrderedTable[Color, Contents]
  DirContainers = OrderedTable[Color, seq[Color]]

let example = """light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.""".PuzzleInput

# need to implement equality of Color otherwise the following line complains:
# not a very nice error by the way (template generic instatiation):
# rules[r.col] = r.con

proc `==`(a,b: Color): bool {.borrow.}

echo "\n---\n"

proc parse(p: PuzzleInput): (Rules, DirContainers) =
  var
    r: Rule
    rules = initOrderedTable[Color, Contents]()
    dirC = initOrderedTable[Color, seq[Color]]()
  for line in p.splitLines:
    r = parseRule line
    rules[r.col] = r.cons
    for con in r.cons:
      if con.col not_in dirC:
        dirC[con.col] = @[r.col]
      elif con.col not_in dirC[con.col]:
        dirC[con.col].add r.col
  for col in colors.keys:
    if col.toColor not_in dirC:
      dirC[col.toColor] = newSeq[Color]()
  return (rules, dirC)

var
  (rs, dcs) = parse example
echo "Rules:"
for k, v in rs:
  echo k, ": ", v
echo "DirContainers:"
for k, v in dcs:
  echo k, ": ", v

echo "\n---\n"

import sets
type AllContainers = OrderedSet[Color]

proc allContainers(c: Color, dc: DirContainers, ac: var AllContainers) =
  for cx in dc[c]:
    if cx in ac:
      ac.incl cx
    else:
      ac.incl cx
      allContainers(cx, dc, ac)

var ac: AllContainers
(0.Color).allContainers(dcs, ac)
echo ac

echo "\n---\n"

var ind = 0

proc reqBags(c: Color, rs: Rules): int =
  ind += 2
  #echo ("color: " & $c).indent(ind)
  #echo ("contents: " & $(rs[c])).indent(ind)
  for con in rs[c]:
    result += con.qty
    result += con.qty*(reqBags(con.col, rs))
  #echo ("result: " & $result).indent(ind)
  ind -= 2

echo "reqBags(example):\n", (0.Color).reqBags(rs)

echo "\n---\n"

let input = "2020/input07.txt".readFile.PuzzleInput
# reset globals
names = @[]
colors = initOrderedTable[string, Color]()
addColor "shiny gold"

ac = initOrderedSet[Color]()

(rs, dcs) = parse input
(0.Color).allContainers(dcs, ac)
echo ac.len

echo "\n---\n"

echo "reqBags(input):\n", (0.Color).reqBags(rs)