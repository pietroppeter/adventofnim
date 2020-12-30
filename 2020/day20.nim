import animu
ddebug

let example = """Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###..."""

import tables, strscans, strutils, sequtils, algorithm, hashes, sugar, options, std/enumerate

type
  Tiles = Table[int, string]

func parse(text: string): Tiles =
  var
    id: int
    tile: seq[string]
  for line in text.splitLines:
    if line.startsWith("Tile"):
      if id != 0:
        result[id] = tile.join("\n")
      if not scanf(line, "Tile $i:", id):
        debugEcho "error parsing line ", line
      tile = @[]
      continue
    if line == "":
      continue
    tile.add line
  result[id] = tile.join("\n")

let exTiles = parse example
echo exTiles.len
for id, tile in exTiles:
  echo "Tile ", id, ":\n", tile

func rotateLeft(tile: string): string =
  let lines = toSeq(tile.splitlines)
  var newLines = newSeq[string](len=lines.len)
  for line in lines:
    for i, c in line:
      newLines[^(i+1)].add c
  result = newLines.join("\n")

func flipVertical(tile: string): string =
  reversed(toSeq(tile.splitlines)).join("\n")
    
let tile2 = "12\n34"
echo tile2, "\n\n", rotateLeft(tile2), "\n\n", flipVertical(tile2)

type
  Transformation {.pure.} = enum
    I, R, R2, R3, F, FR, FR2, FR3

func transform(tile: string, tr: Transformation): string =
  case tr:
    of I:
      tile
    of R:
      rotateLeft tile
    of R2:
      rotateLeft(rotateLeft tile)
    of R3:
      rotateLeft(rotateLeft(rotateLeft tile))
    of F:
      flipVertical tile
    of FR:
      rotateLeft(flipVertical tile)
    of FR2:
      rotateLeft(rotateLeft(flipVertical tile))
    of FR3:
      rotateLeft(rotateLeft(rotateLeft(flipVertical tile)))

for tr in Transformation:
  echo tr, ":\n", "12\n34".transform tr, "\n"

func transformsTo(tile1, tile2: string): Option[Transformation] =
  for tr in Transformation:
    if (tile1.transform tr) == tile2:
      return some(tr)

let exTopLeft = """#...##.#..
..#.#..#.#
.###....#.
###.##.##.
.###.#####
.##.#....#
#...######
.....#..##
#.####...#
#.##...##."""

dump (exTiles[1951].transformsTo exTopLeft) # some(F)

type
  Direction {.pure.} = enum
    Top, Right, Bottom, Left
  OrientedBorder = tuple[str: string, dir: Direction] # I can avoid this 

func firstLine(tile: string): string =
  for c in tile:
    if c == '\n':
      break
    result.add c

func lastLine(tile: string): string =
  toSeq(tile.splitLines)[^1]

func border(tile: string, dir: Direction): OrientedBorder =
  case dir:
    of Top: (firstLine(tile), dir)
    of Right: (firstLine(rotateLeft tile), dir)
    of Bottom: (lastLine(tile), dir)
    of Left: (lastLine(rotateLeft tile), dir)

for dir in Direction:
  echo border("12\n34", dir)

func opposite(dir: Direction): Direction =
  case dir:
    of Top: Bottom
    of Bottom: Top
    of Right: Left
    of Left: Right

func match(b, c: OrientedBorder): bool =
  b.dir == c.dir.opposite and b.str == c.str

type
  Match = tuple[id: int, tr: Transformation, dir: Direction]

func match(t1, t2: string): Option[tuple[tr: Transformation, dir: Direction]] =
  var t: string
  for tr in Transformation:
    t = t2.transform tr  
    for dir in Direction:
      if t1.border(dir).match(t.border(dir.opposite)):
        return some (tr, dir)

func match(tiles: Tiles; id1, id2: int): Option[Match] =
  let tile1 = tiles[id1]
  for tr in Transformation:
    let tile2 = tiles[id2].transform tr
    for dir in Direction:
      if tile1.border(dir).match(tile2.border(dir.opposite)):
        return some (id2, tr, dir)

assert exTiles.match(1951, 2311).isSome
assert exTiles.match(1951, 2729).isSome
assert not exTiles.match(1951, 1427).isSome

type Matches = Table[int, seq[Match]]

func findMatches(tiles: Tiles): Matches =
  var m: Option[Match]
  for id1, tile1 in tiles:
    for id2, tile2 in tiles:
      if id1 == id2: continue
      m = tiles.match(id1, id2)
      if m.isSome:
        if id1 in result:
          result[id1].add m.get
        else:
          result[id1] = @[m.get]

func findCorners(matches: Matches): seq[int] =
  var numMatches: int
  for id, matchIds in matches:
    numMatches = matchIds.len
    if numMatches == 2: result.add id

let
  exMatches = exTiles.findMatches
  exCorners = exMatches.findCorners
assert exCorners.len == 4

var part1 = 1
for id in exCorners:
  part1 *= id
echo "part1, example: ", part1
assert part1 == 20899048083289

let
  input = "2020/input20.txt".readFile
  inTiles = parse input
dump inTiles.len
let
  inMatches = inTiles.findMatches
  inCorners = inMatches.findCorners
dump inCorners
assert inCorners.len == 4
part1 = 1
for id in inCorners:
  part1 *= id
echo "part1, input: ", part1
assert part1 == 17712468069479

echo "\n---\n"
# part2 - strategy: set a topLeft corner and match row by row
# 1. find a topLeft corner
# - I need to keep track of tile and their orientation
# - I need to be able to compose transformations
# - for convenience I want a shorthand for Horizontal Flip

assert ("12\n34".transformsTo "21\n43").isSome
const HF = ("12\n34".transformsTo "21\n43").get

func findComposition(tr1, tr2: Transformation): Transformation =
  const tile = "12\n34"
  for tr in Transformation:
    if (tile.transform tr) == (tile.transform tr1).transform tr2:
      return tr

func compositionTable: array[Transformation, array[Transformation, Transformation]] =
  for tr1 in Transformation:
    for tr2 in Transformation:
      let tr = findComposition(tr1, tr2)
      result[tr1][tr2] = tr  

func `*`(tr1, tr2: Transformation): Transformation =
  const cTable = compositionTable()
  result = cTable[tr1][tr2]

type
  OrientedTile = tuple[id: int, tr: Transformation]

func asTopLeft(id: int, matches: seq[Match]): OrientedTile =
  var tr: Transformation
  tr = I
  for other in matches:
    case other.dir:
      of Right, Bottom:
        continue
      of Top:
        tr = tr * F
      of Left:
        tr = tr * HF
  result = (id, tr)

assert exTopLeft == exTiles[1951].transform(asTopLeft(1951, exMatches[1951]).tr)

# to compose Puzzle I will need
# - a way to match a tile to the right of a possibly transformed tile

func next(tile: string, matches: seq[Match], tiles: Tiles, dir: Direction): (int, string) =
  var otherTile: string
  var m: tuple[tr: Transformation, dir: Direction]
  for aMatch in matches:
    otherTile = tiles[aMatch.id]
    m = match(tile, otherTile).get
    if m.dir == dir:
      return (aMatch.id, otherTile.transform m.tr)

proc composePuzzle(tiles: Tiles, matches: Matches): seq[seq[string]] =
  var orTile: OrientedTile
  var id, nextId, idRow: int
  var tile, nextTile: string
  var dir: Direction
  var row: seq[string]
  # top left corner
  for id, matchTiles in matches:
    if matchTiles.len == 2:
      orTile = id.asTopLeft(matchTiles)
      tile = tiles[orTile.id].transform orTile.tr
      row = @[tile]
  # process row by row
  idRow = orTile.id
  id = orTile.id
  decho "topLeft: ", id
  dir = Right
  while true:
    ddump (dir, id)
    (nextId, nextTile) = next(tile, matches[id], tiles, dir)
    ddump (dir, nextId)
    if nextTile == "" and dir == Bottom: # end of process
      return
    elif dir == Bottom: # next row started
      decho "start next row"
      dir = Right
      idRow = nextId
      id = nextId
      tile = nextTile
      row = @[tile]
    elif nextTile == "": # dir = Right, end of row
      decho "end of row"
      ddump idRow
      dir = Bottom
      tile = row[0]
      id = idRow
      result.add row
    else:
      # ok match to the right
      tile = nextTile
      id = nextId
      row.add tile
    
let exComposed = composePuzzle(exTiles, exMatches)

func removeBorders(tile: string): string =
  var lines: seq[string]
  for i, line in enumerate(tile.splitLines):
    if i == 0 or i == 9:
      continue
    lines.add line[1..<line.high]
  result = lines.join("\n")


func joinPuzzleRow(row: seq[string]): string =
  var lines: seq[string]
  for i in 1..8:
    lines.add ""
  for tile in row:
    for i, line in enumerate(tile.removeBorders.splitlines):
      lines[i] &= line
  result = lines.join("\n")

func gluePuzzle(tilesComposed: seq[seq[string]]): string =
  ## removes borders and glue as single string
  tilesComposed.mapIt(it.joinPuzzleRow).join("\n")

let exPuzzle = exComposed.gluePuzzle

const seaMonster = """                  # 
#    ##    ##    ###
 #  #  #  #  #  #   """.splitLines
const monsterLen = seaMonster[0].len
for j in 0..2:
  assert seaMonster[j].len == 20
const monsterCnt = 15

func seeMonster(puzzle: string, i: int, rowLen: int): bool =
  for j in 0..2:
    let ii = i + j*(rowLen + 1)
    for k in 0..<monsterLen:
      if seaMonster[j][k] == '#':
        ddump (j, k, ii)
        ddump seaMonster[j][k]
        ddump puzzle[ii + k]
      if seaMonster[j][k] == '#' and puzzle[ii + k] != '#':
        return false
  return true

func countMonsters(puzzle: string): int =
  let
    lines = puzzle.splitLines
    rowLen = lines[0].len
    rowMax = lines.len
  for j in 0..<(rowMax - 2):
    for k in 0..(rowLen - monsterLen):
      let i = k + j*(rowLen + 1)
      if seeMonster(puzzle, i, rowLen):
        inc result

func findMonsters(puzzle: string): int =
  for tr in Transformation:
    result = countMonsters(puzzle.transform tr)
    if result > 0:
      return

dump findMonsters(exPuzzle)  # 2

func seaRoughness(puzzle: string): int =
  var puzzleCnt = 0
  for c in puzzle:
    if c == '#':
      inc puzzleCnt
  return puzzleCnt - findMonsters(puzzle)*monsterCnt

dump seaRoughness(exPuzzle)

when false: # used to debug
  for tr in Transformation:
    if (exPuzzle.transform tr).startsWith(".####...#####..#"):
      echo tr #R

  dump seeMonster(exPuzzle.transform R, 52, 24)

let
  inComposed = composePuzzle(inTiles, inMatches)
  inPuzzle = inComposed.gluePuzzle

dump seaRoughness(inPuzzle) #2173
