import animu, nimib

nbInit(theme=useAdventOfNim)
nbText: """## Day 14: [Extended Polymerization](https://adventofcode.com/2021/day/14)

Today is a chemistry day!

### Part 1

Parsing is straightforward
"""

nbCode:
  type Rules = Table[string, char]
  func parse(text: string): Rules =
    result = initTable[string, char]()
    for line in text.splitLines:
      result[line[0 .. 1]] = line.strip[^1]

  let
    testTemplate = "NNCB"
    puzzleTemplate = "VNVVKSNNFPBBBVSCVBBC"
    testRules = parse """
CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C"""
    puzzleRules = parse readFile("2021/input14.txt")
  dump testRules["BB"]
  dump testRules.len
  dump puzzleRules["BB"]
  dump puzzleRules.len
nbText: "Let's write the evolution function:"
nbCode:
  func tick(rules: Rules, polymer: string): string =
    result.add polymer[0]
    for i in 0 ..< polymer.high: # until 1 less than highest index
      let pair = polymer[i .. (i+1)]
      if pair in rules:
        result.add rules[pair]
      result.add polymer[i+1]

  func tickN(rules: Rules, polymer: string, n=10): string =
    result = polymer
    for i in 1 .. n:
      result = rules.tick result
      debugEcho i, ": ", result.len
    
  dump testRules.tick testTemplate
  dump testRules.tickN(testTemplate, n=2)
  dump testRules.tickN(testTemplate, n=3)
  dump testRules.tickN(testTemplate, n=4)
nbText: "and let's solve part 1"
nbCode:
  func part1(rules: Rules, polymer: string, n=10): int =
    let polymer = rules.tickN(polymer, n)
    var elementCountTable = polymer.toCountTable
    elementCountTable.sort() # default order is descending
    let
      keys = toSeq(elementCountTable.keys)
      counts = toSeq(elementCountTable.values)
    debugEcho "max: ", keys[0], " -> ", counts[0]
    debugEcho "min: ", keys[^1], " -> ", counts[^1]
    counts[0] - counts[^1]

  dump part1(testRules, testTemplate)
  dump part1(puzzleRules, puzzleTemplate)
gotTheStar
nbText: """all good except I did not read well and first implemented a function to count pairs
and not use the builtin for counting single elements (hence the `debugEchos`)

## Part 2

ok, here clearly the brute force approach we used is not supposed to work and I am pretty sure
I am going to need the `countPairs` I just deleted...
"""
nbCode:
  # had to try anyway, but after a few seconds I stopped
  #dump part1(testRules, testTemplate, n=40)
  #dump part1(puzzleRules, puzzleTemplate, n=40)
  discard # cannot have a code block with only comments!

nbCode:
  type CountPairs = CountTable[string]
  
  func getCountPairs(polymer: string): CountPairs =
    result = initCountTable[string]()
    for i in 0 ..< polymer.high:
      let pair = polymer[i .. (i+1)]
      result.inc pair

  func tick(rules: Rules, countPairs: CountPairs): CountPairs =
    result = initCountTable[string]()
    for pair in countPairs.keys:
      if pair in rules:
        let
          count = countPairs[pair]
          newPairLeft = pair[0] & rules[pair]
          newPairRight = rules[pair] & pair[1]
        result.inc(newPairLeft, count)
        result.inc(newPairRight, count)
  
  func tickN(rules: Rules, countPairs: CountPairs, n=40): CountPairs =
    result = countPairs
    for i in 1 .. n:
      result = rules.tick result
      debugEcho i, ": ", result.len # how many pairs

  func part2(rules: Rules, polymer: string, n=40): int =
    var countPairs = polymer.getCountPairs
    countPairs = rules.tickN(countPairs, n)
    var elementCountTable = initCountTable[char]()
    for pair, count in countPairs:
      elementCountTable.inc(pair[1], val=count)
    elementCountTable.inc(polymer[0]) # need to count again first element
    elementCountTable.sort() # default order is descending
    let
      keys = toSeq(elementCountTable.keys)
      counts = toSeq(elementCountTable.values)
    debugEcho "max: ", keys[0], " -> ", counts[0]
    debugEcho "min: ", keys[^1], " -> ", counts[^1]
    counts[0] - counts[^1]

  dump part2(testRules, testTemplate, n=10)
  dump part2(puzzleRules, puzzleTemplate, n=10)
nbText: "ok, checks out with part 1"
nbCode:
  dump part2(testRules, testTemplate, n=40)
  dump part2(puzzleRules, puzzleTemplate, n=40)
gotTheStar
nbText: "surprised I got the second part at first try (had to think a bit to get it correct)!"
nbSave