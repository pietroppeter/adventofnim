import batteries, aoc22, nimib, p5
let day = Day(
  num: 3,
  title: "Rucksack Reorganization",
  summary: ""
)
nbInit
nbUseP5
nbJsFromCode:
  import p5aoc
nb.darkMode
nbText: day.mdTitle
nbText: "parsing input"
nbCode:
  proc parse(text: string): seq[(string, string)] =
    for line in text.splitLines:
      assert line.len mod 2 == 0
      result.add (line[0 ..< (line.len div 2)], line[(line.len div 2) .. line.high])

  let sacks = parse(day.filename.readFile)
  for i in 0..2:
    echo sacks[i][0]
    echo sacks[i][1]
    echo ""
  echo "#sacks: ", len sacks
  echo "max len compartment: ", max(sacks.mapIt(it[0].len))
nbText: "find matching character (not caring much about performance)"
nbCode:
  func match(sack: (string, string)): char =
    for c in sack[1]:
      if c in sack[0]:
        return c

  let example = """
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"""
  let exampleSacks = parse example

  echo exampleSacks.mapIt(match it) # expect pLPvts
nbText: "computing priority"
nbCode:
  func priority(c: char): int =
    if c.isLowerAscii:
      c.ord - 'a'.ord + 1
    elif c.isUpperAscii:
      c.ord - 'A'.ord + 27
    else:
      0

  func part1(sacks: seq[(string, string)]): int =
    sum sacks.mapIt(priority match it)

  echo part1 exampleSacks # expect 157
  echo part1 sacks
gotTheStar
nbText: "group match"
nbCode:
  func toSet(sack: (string, string)): HashSet[char] =
    toHashSet(sack[0]) + toHashSet(sack[1])

  func groupMatch(sacks: seq[(string, string)]): char =
    var matches: HashSet[char]
    for sackSet in sacks.mapIt(toSet it):
      if matches.len == 0:
        matches = sackSet
      else:
        matches = matches * sackSet
    for c in matches:
      return c

  echo groupMatch(exampleSacks[0..2]) # r
  echo groupMatch(exampleSacks[3..5]) # Z
nbCode:
  func part2(sacks: seq[(string, string)]): int =
    assert (len sacks) mod 3 == 0
    var i = 0
    while i < len sacks:
      result += priority groupMatch(sacks[i ..< i + 3])
      inc i, 3

  echo part2 exampleSacks # 70
  echo part2 sacks
nbSave