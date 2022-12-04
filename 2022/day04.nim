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

let dayInput = day.filename.readFile

template myJsWithCaptures0(body: untyped) =
  nbJsFromCode(dayInput):
    import batteries
    body

nbCodeAnd(myJsWithCaptures0):
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

  let assignmentList = parse dayInput
  echo assignmentList[0..1]
  echo len assignmentList

nbCodeAnd(nbJsFromCode):
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
nbCodeAnd(nbJsFromCode):
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
nbCodeAnd(nbJsFromCode):
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
nbCode:
  echo max assignmentList.mapIt(max(it[0].b, it[1].b))

nbCodeDisplay(nbJsFromCode):
  var t = -20
  const h0 = 30
  var p1, p2 = 0

  proc draw(s: Section, x, y: int) =
    rect(x + s.a, y + 1, s.b - s.a, 8)

  proc drawTable() =
    background(colDark)
    stroke(colBackground)
    line(0, h0, 1000, h0)
    for i in 1..9:
      line(i*100, h0, i*100, h0 + 1000)

  proc drawScore() =
    stroke(colGold & "55")
    fill(colGold)
    text("part 1: " & $p1, 200, 20)
    text("part 2: " & $p2, 700, 20)

  proc clearScore() =
    fill(colDark)
    noStroke()
    rect(0, 0, 1000, 29)

  func `*`(s1, s2: Section): Section =
    if s1 <: s2:
      result.a = s2.a
      result.b = s1.b
    elif s2 <: s1:
      result.a = s1.a
      result.b = s2.b

  setup:
    createCanvas(1000, h0 + 1000)
    drawTable()
    drawScore()

  draw:
    if t >= 0 and t <= assignmentList.high:
      let x = (t div 100)*100
      let y = h0 + (t mod 100)*10
      let (s1, s2) = assignmentList[t]
      fill(colTransparent)
      stroke(colGreen & "cc")    
      draw(s1, x, y)
      stroke(colRust & "cc")
      draw(s2, x, y)
      if s1 < s2:
        noStroke()
        fill(colGreen & "44")
        draw(s1, x, y)
        inc p1
        inc p2
      elif s2 < s1:
        noStroke()
        fill(colRust & "44")
        draw(s2, x, y)
        inc p1
        inc p2
      elif overlap(s1, s2):
        noStroke()
        fill(colGold & "44")
        draw(s1*s2, x, y)
        inc p2

      clearScore()
      drawScore()
    inc t
    if t > assignmentList.high + 360:
      drawTable()
      clearScore()
      t = -20
      p1 = 0
      p2 = 0
      drawScore()
nbVizHere

nbSave