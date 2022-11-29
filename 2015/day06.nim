import nimib, p5

nbInit
nbUseP5
nbCode:
  import batteries

  let example = """
  toggle 461,550 through 564,900
  turn off 370,39 through 425,839
  turn off 464,858 through 833,915
  turn off 812,389 through 865,874
  turn on 599,989 through 806,993
  turn on 376,415 through 768,548
  turn on 606,361 through 892,600
  turn off 448,208 through 645,684
  toggle 50,472 through 452,788
  toggle 205,417 through 703,826
  """

  type
    MoveKind = enum
      mkToggle, mkOn, mkOff
    Move = object
      kind: MoveKind
      x0, y0, x1, y1: int

  proc parse(input: string, reduced = false): seq[Move] =
    var m: Move
    for line in input.splitLines:
      if scanf(line, "toggle $i,$i through $i,$i", m.x0, m.y0, m.x1, m.y1):
        m.kind = mkToggle
      elif scanf(line, "turn on $i,$i through $i,$i", m.x0, m.y0, m.x1, m.y1):
        m.kind = mkOn
      elif scanf(line, "turn off $i,$i through $i,$i", m.x0, m.y0, m.x1, m.y1):
        m.kind = mkOff
      else:
        echo "no match, line: ", line
        continue
      if reduced:
        m.x0 = m.x0 div 10
        m.y0 = m.y0 div 10
        m.x1 = m.x1 div 10
        m.y1 = m.y1 div 10

      result.add m

  echo parse(example, reduced=true)
nbCodeDisplay(nbP5Instance):
  type
    Light = object
      x, y, r0, r: float
      isOn: bool

  proc initLight(x, y: float): Light =
    result.x = x
    result.y = y
    result.r0 = 20.0

  proc move(l: var Light) =
    if l.isOn and l.r < l.r0:
      l.r = l.r + 1
    elif not l.isOn and l.r > 0:
      l.r = l.r - 1

  proc show(l: var Light) =
    ellipse(l.x, l.y, l.r)

  var l: Light

  setup:
    createCanvas(100, 100)
    background(0)
    fill(250)
    l = initLight(50.0, 50.0)
  
  draw:
    l.move
    l.show
    if frameCount mod 100 == 50:
      l.isOn = true
    elif frameCount mod 100 == 0:
      l.isOn = false
    #echo l
nbSave