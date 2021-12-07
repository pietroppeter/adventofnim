#[
  - optimal point is for sure inside
  - for 
]#
import animu, nimib
nbInit(theme=useAdventOfNim)
nbText: """## Day 7: [The Treachery of Whales]
[The Treachery of Whales]: https://adventofcode.com/2021/day/7

"""
nbCode:
  let
    puzzleInput = readFile("2021/input07.txt").strip.split(',').map(parseInt)
    testInput = @[16,1,2,0,4,2,7,1,2,14]

  echo len(puzzleInput)
  echo min(puzzleInput)
  echo max(puzzleInput)
nbCode:
  # assume min = 0
  func cost(crab: int, max: int): seq[int] =
    result = newSeqWith(len=max + 1): 0
    for i in 0 .. result.high:
      result[i] = abs(crab - i)
  func cost(crabs: seq[int]): seq[int] =
    let max = max(crabs)
    result = newSeqWith(len=max + 1): 0
    for crab in crabs:
      for i, c in cost(crab, max):
        result[i] += c
  func part1(crabs: seq[int]): int =
    let c = cost(crabs)
    min(c)
  dump part1(testInput)
  dump part1(puzzleInput)

gotTheStar

nbCode:
  func cost2(crab: int, max: int): seq[int] =
    result = newSeqWith(len=max + 1): 0
    for i in 0 .. result.high:
      let n = abs(crab - i)
      result[i] = n * (n + 1) div 2 
  func cost2(crabs: seq[int]): seq[int] =
    let max = max(crabs)
    result = newSeqWith(len=max + 1): 0
    for crab in crabs:
      for i, c in cost2(crab, max):
        result[i] += c
  func part2(crabs: seq[int]): int =
    let c = cost2(crabs)
    min(c)
  dump cost2(16, 16)[5]
  dump cost2(0, 16)[5]
  dump cost2(7, 16)[5]
  dump part2(testInput)
  dump part2(puzzleInput)

gotTheStar

nbSave