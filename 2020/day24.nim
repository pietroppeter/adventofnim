import npeg, sequtils, strutils

var ss: seq[seq[string]]

type
  Direction {.pure.} = enum
    e, se, sw, w, nw, ne

proc parse(text: string): seq[seq[Direction]] =
  var
    res: seq[seq[Direction]] # also to note: result cannot be used in blocks
    s: seq[string]

  let p = peg("lines"):
    lines <- +line
    line <- +(>direction) * "\n":
      s = capture.capList.mapIt(it.s)[1..<capture.len] # is there a better way to do this in npeg?
      res.add s.mapIt(parseEnum[Direction](it)) # I was not able to put parseEnum directly above, why?
    direction <- "e" | "se" | "sw" | "w" | "nw" | "ne"
  if not p.match(text).ok:
    echo "Error parsing"
  return res

let example = """sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew
"""

for line in parse example:
  echo line

type
  HexCoord = tuple[e: int, ne: int]

func toHexCoord(s: seq[Direction]): HexCoord =
  for dir in s:
    case dir:
      of e:
        inc result.e
      of w:
        dec result.e
      of ne:
        inc result.ne
      of sw:
        dec result.ne
      of nw:
        dec result.e
        inc result.ne
      of se:
        inc result.e
        dec result.ne

echo @[e, se, w].toHexCoord
echo @[nw, w, sw, e, e].toHexCoord

import tables

type Floor = Table[HexCoord, bool]
func flip(list: seq[seq[Direction]]): Floor =
  var hexCoord: HexCoord
  for tile in list:
    hexCoord = tile.toHexCoord
    if hexCoord in result:
      result[hexCoord] = not result[hexCoord]
    else:
      result[hexCoord] = true

func countBlacks(t: Floor): int =
  for k, v in t:
    if v:
      inc result

echo countBlacks(flip(parse example)) # 10
echo (parse example).len

let input = "2020/input24.txt".readFile.replace("\c", "")
echo "part1: ", countBlacks(flip(parse input))

iterator adjacents(tile: HexCoord): HexCoord =
  var tile = tile
  inc tile.ne
  yield tile
  dec tile.ne
  inc tile.e
  yield tile
  dec tile.ne
  yield tile
  dec tile.e
  yield tile
  inc tile.ne
  dec tile.e
  yield tile
  inc tile.ne
  yield tile

for tile in adjacents (0, 0):
  echo tile

func next(floor: Floor): Floor =
  var today = floor
  # first augment the floors with white neighbours that might become black
  for tile in floor.keys:
    for otherTile in adjacents tile:
      if otherTile notin today:
        today[otherTile] = false
  var tomorrow = today
  var countAdjBlacks: int
  for tile, isBlack in today:
    countAdjBlacks = 0
    for otherTile in adjacents tile:
      if otherTile in today and today[otherTile]:
        inc countAdjBlacks
    if isBlack and (countAdjBlacks == 0 or countAdjBlacks > 2):
      tomorrow[tile] = false
    if not isBlack and countAdjBlacks == 2:
      tomorrow[tile] = true
  return tomorrow

var floor = flip(parse example)
echo "Day 0: ", countBlacks(floor)
for day in 1..100:
  floor = next(floor)
  if day <= 10 or day mod 10 == 0:
    echo "Day ", day, ": ", countBlacks(floor)
  if day == 11:
    echo ""

floor = flip(parse input)
for day in 1..100:
  floor = next(floor)
echo "part2: ", countBlacks(floor)