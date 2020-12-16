import strutils, sequtils, strscans, tables, options

type
  Rule = tuple[field: string, a, b, c, d: int]
  Ticket = seq[int]
  PuzzleInput = tuple
    rules: seq[Rule]
    myTicket: Ticket
    nearbyTickets: seq[Ticket]
    fields: seq[string]  ## added for part2

proc parseRule(line: string): Rule =
  if not scanf(line, "$+: $i-$i or $i-$i", result.field, result.a, result.b, result.c, result.d):
    echo "parseRuleError in line: ", line

proc parseTicket(line: string): Ticket =
  try:
    return line.split(",").map(parseInt)
  except ValueError:
    echo "parseTicketError in line: ", line

proc parse(text: string): PuzzleInput =
  let lines = text.splitLines
  var i = 0
  while lines[i] != "":
    result.rules.add parseRule(lines[i])
    inc i
  result.fields = result.rules.mapIt(it.field)
  inc i
  if lines[i] != "your ticket:":
    echo "parseError: expected line with 'your ticket:'"
  inc i
  result.myTicket = parseTicket(lines[i])
  inc i
  inc i
  if lines[i] != "nearby tickets:":
    echo "parseError: expected line with 'nearby tickets:'"
  inc i
  while i < lines.len:
    result.nearbyTickets.add parseTicket(lines[i])
    inc i

let example = """class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12"""

echo parse example

func satisfy(n: int, r: Rule): bool = (n >= r.a and n <= r.b) or (n >= r.c and n <= r.d)

proc isValidForSome(n: int, rules: seq[Rule]): bool =
  for r in rules:
    if n.satisfy(r):
      return true
  return false # not necessary but being explicit

proc scanError(ticket: Ticket, rules: seq[Rule]): int =
  for value in ticket:
    if not value.isValidForSome(rules):
      result += value

proc solve1(p: PuzzleInput): int =
  for ticket in p.nearbyTickets:
    result += ticket.scanError(p.rules)

echo solve1(parse example)

var input = parse("2020/input16.txt".readFile)
echo solve1(input)
echo "input.fields: ", input.fields
echo "input.fields.len: ", input.fields.len

proc clean(p: var PuzzleInput) =
  echo "nearby tickets before cleaning: ", p.nearbyTickets.len
  var cleanedTickets: seq[Ticket]
  for t in p.nearbyTickets:
    if t.scanError(p.rules) == 0:
      cleanedTickets.add t
  p.nearbyTickets = cleanedTickets
  echo "nearby tickets after cleaning: ", p.nearbyTickets.len

clean input

func allKnown(ss: seq[string]): bool =
  for s in ss:
    if s == "":
      return false
  return true

func satisfy(ts: seq[Ticket], i: int, r: Rule): bool =
  for t in ts:
    if not t[i].satisfy(r):
      return false
  return true

func cnt(s: seq[bool]): int =
  for t in s:
    if t: inc result

#[
example
  [0, 1, 2],
  [2]
  [0, 1]
-> this is a solution
  [0, 2, 1]
maybe not unique but uniqueness should be guaranteed by generation of puzzle input

first step:
[2] is minimal length

ask to solve for
[0, 1]
[0, 1]

pick 0 from first sequence:
ask to solve for 
[1]

easy solution pick 1
now partial solution is [0, 1]

solution is [0, 1]
add 2 back in the place where it should be
]#
var ind = 0
proc solve(ss: seq[seq[int]]): Option[seq[int]] =
  #echo indent("solve:", ind)
  #echo indent(ss.mapIt($(it)).join("\n"), ind + 2)
  if ss.len == 1 and ss[0].len > 0:
    return some(@[ss[0][0]])
  # this is going to be quite recursive
  var
    m = int.high
    j: int
    r: seq[int]
  # find sequence with minimal length
  for i, s in ss:
    if s.len < m:
      m = s.len
      j = i
  if m == 0:  # cannot solve
    #echo indent("cannot solve minimal length = 0", ind)
    return none(seq[int])
  # try to solve it with elements from minimal length seq
  #echo indent("minimal length, index, ss[j]" & $(m, j, ss[j]), ind)
  for n in ss[j]:
    #echo indent("n: " & $n, ind)
    # remove n from ss and try to solve
    var tt: seq[seq[int]]
    for i, s in ss:
      tt.add @[]
      for m in s:
        if m != n:
          tt[^1].add m
      if tt[^1].len == 0:
        discard tt.pop
    inc ind, 2
    let tr = solve tt
    dec ind, 2
    if tr.isSome:
      for i, m in tr.get():
        if i == j:
          r.add n
        r.add m
      if j == tr.get().len:
        r.add n
      return some(r)
  return none(seq[int])

proc solve2(p: var PuzzleInput) =
  let n = p.myTicket.len
  p.fields.setLen(n)
  var possibleFields = newSeq[seq[string]](len=n)
  for i in 0 ..< n:
    for rule in p.rules:
      if p.nearbyTickets.satisfy(i, rule):
        # assuming first rule found to satisfy is correct
        possibleFields[i].add rule.field
  #echo possibleFields
  let fields = p.rules.mapIt(it.field)
  # let's make the problem a problem of ints instead of strings
  var fieldToInt = initTable[string, int]()
  for i, field in fields:
    fieldToInt[field] = i
  var possibleInts: seq[seq[int]]
  for s in possibleFields:
    possibleInts.add s.mapIt(fieldToInt[it])
  
  let solution = solve possibleInts
  if solution.isSome:
    p.fields = solution.get.mapIt(fields[it])
  else:
    echo "can't solve"
    quit(1)

solve2 input
echo input.fields
echo input.fields.len
var part2 = 1
for i, field in input.fields:
  echo "i, field:", (i, field)
  if field.startsWith("departure"):
    echo "  ", input.myTicket[i]
    part2 *= input.myTicket[i]
echo part2
## 6178448659 too low