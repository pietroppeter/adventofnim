import animu

type
  CaveNode = seq[string]
  CaveGraph = Table[string, CaveNode]

func add(g: var CaveGraph, path: (string, string)) =
  if path[0] in g:
    g[path[0]].add path[1]
  else:
    g[path[0]] = @[path[1]]

func parse(text: string): CaveGraph =
  for line in text.splitLines:
    let path = line.split('-')
    assert path.len == 2
    result.add (path[0], path[1])
    result.add (path[1], path[0])

let
  sample1 = """
start-A
start-b
A-c
A-b
b-d
A-end
b-end"""
  cave1 = parse sample1

echo cave1

func isSmall(s: string): bool =
  for c in s:
    if not c.isLowerAscii: return false
  true

func allPaths(g: CaveGraph, history: seq[string] = @["start"]): seq[seq[string]] =
  assert history.len > 0
  let last = history[^1]
  assert last in g
  if last == "end":
    return @[history]
  for next in g[last]:
    if next.isSmall and next in history:
      continue # not a valid path
    else:
      result &= g.allPaths(history & next)

#[
  improvements:
    - make isSmall an attribute of cave
    - map names to ints
]#

for p in cave1.allPaths:
  echo p
echo len(cave1.allPaths)

func part1(g: CaveGraph): int = len(g.allPaths)

let
  sample2 = """
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc"""
  sample3 = """
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW"""
  cave2 = parse sample2
  cave3 = parse sample3

dump part1 cave2
dump part1 cave3

let
  puzzle = """
pg-CH
pg-yd
yd-start
fe-hv
bi-CH
CH-yd
end-bi
fe-RY
ng-CH
fe-CH
ng-pg
hv-FL
FL-fe
hv-pg
bi-hv
CH-end
hv-ng
yd-ng
pg-fe
start-ng
end-FL
fe-bi
FL-ks
pg-start"""
  caveP = parse puzzle

dump part1 caveP

func valid(next: string, history: seq[string]): bool =
  if next == "start":
    return false
  if not next.isSmall:
    return true
  var countTable = initCountTable[string]()
  var max = 0
  for cave in history:
    if cave.isSmall:
      countTable.inc cave
    if countTable[cave] > max:
      max = countTable[cave]
  if countTable[next] == 0 or (countTable[next] == 1 and max <= 1):
    return true
  return false

func allPaths2(g: CaveGraph, history: seq[string] = @["start"]): seq[seq[string]] =
  assert history.len > 0
  let last = history[^1]
  assert last in g
  if last == "end":
    return @[history]
  for next in g[last]:
    if not next.valid(history):
      continue # not a valid path
    else:
      result &= g.allPaths2(history & next)

func part2(g: CaveGraph): int = len(g.allPaths2)

for p in cave1.allPaths2:
  echo p
dump part2 cave1
dump part2 cave2
dump part2 cave3
dump part2 caveP
