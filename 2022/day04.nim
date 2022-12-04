import batteries, aoc22, nimib, p5
let day = Day(
  num: 4,
  title: "Camp Cleanup",
  summary: ""
)
nbInit
nbUseP5
nbJsFromCode:
  import p5aoc
nb.darkMode
nbText: day.mdTitle

nbPart1

nbCode:
  type
    Section = tuple[a, b: int]
    SectionPairs = (Section, Section)

  func parse(text: string): seq[SectionPairs] =
    var sp: SectionPairs
    for line in text.splitLines:
      if not scanf(line, "$i-$i,$i-$i", sp[0].a, sp[0].b, sp[1].a, sp[1].b):
        debugEcho "ERROR, line: '", line, "'"
      else:
        result.add sp

  let assignmentList = parse day.filename.readFile
  echo assignmentList[0..1]
  echo len assignmentList

nbCode:
  func `<`(s1, s2: Section): bool =
    (s1.a <= s2.a and s1.b >= s2.b)
  
  func oneInTheOther(s1, s2: Section): bool =
    s1 < s2 or s2 < s1

  func part1(inp: seq[SectionPairs]): int =
    for sp in inp:
      if oneInTheOther(sp[0], sp[1]):
        inc result

  echo part1 assignmentList
# 803 too high
nbText: "debugging with example"
nbCode:
  let example = """
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8"""
  echo part1 parse example # expect 2
nbText: "had a wrong sign"
gotTheStar
nbPart2
nbCode:
  func `<:`(s1, s2: Section): bool =
    (s1.a <= s2.a and s1.b >= s2.a)

  func overlap(s1, s2: Section): bool =
    s1 <: s2 or s2 <: s1    

  func part2(inp: seq[SectionPairs]): int =
    for sp in inp:
      if overlap(sp[0], sp[1]):
        inc result

  echo part2 parse example # expect 4
  echo part2 assignmentList
gotTheStar
nbAround


nbViz


nbSave