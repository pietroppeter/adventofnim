import nimib, animu
import npeg

nbInit

nbText: "# --- Day 7: Handy Haversacks ---"

nbText: """
Today I want to clarify my solving plan beforehand with types (as I usually do)
and forward declarations of procs.
I will also forward declare my variables (some could be let but that's opimization and left for later).
Finally I will declare templates to test my implementation on the given example and to solve part1.
"""

nbCode:
  type ## I am being very redundant to make very explicit later on the proc forward declarations
    PuzzleInput = string
    Color = distinct int
    Names = seq[string]
    ## I like my tables and set to be ordered so that I can check algorithm flows
    Colors = OrderedTable[string, Color]
    Rules = OrderedTable[Color, Contents]
    Rule = tuple[col: Color, con: Contents]
    Contents = seq[tuple[qty: int, col: Color]]
    DirContainers = OrderedTable[Color, seq[Color]]
    AllContainers = OrderedSet[Color]
  var
    names: Names  ## e.g. names[0] -> "shiny gold"
    colors: Colors ## e.f. colors["shiny gold"] -> 0.Color
    rules: Rules ## e.g. "light red" -> (1, "bright white") & (2, "muted yellow")
    dirContainers: DirContainers # e.g. "shiny gold" -> "bright white" or "muted yellow"
    example, input: PuzzleInput
  ## procs:
  proc `$`(c: Color): string
  proc toColor(name: string): Color
  proc loadExample: PuzzleInput = discard
  proc loadInput: PuzzleInput = discard
  proc parseRule(s: string): Rule
  proc parse(pinp: PuzzleInput): (Names, Colors, Rules, DirContainers) = discard
  proc allContainers(c: Color, dc: DirContainers): AllContainers = discard

  ## templates
  template iterEcho(c: untyped) =  # for containers of complex object I want one string for each line (put in animu?)
    for i, x in c:
      echo i, ": ", x
  template test =
    echo "light red bags contain 1 bright white bag, 2 muted yellow bags.".parseRule
    echo "bright white bags contain 1 shiny gold bag.".parseRule
    echo "faded blue bags contain no other bags.".parseRule
    example = loadExample
    (names, colors, rules, dirContainers) = parse example
    echo names ## shiny gold, ... (plan to put shiny gold at place 0)
    echo names.len ## 9
    iterEcho colors ## 0 : shiny gold, ...
    iterEcho rules ## light red : [(1, bright white), (Z, C2)], ...
    let exampleContainers = allContainers(0.Color, dirContainers)
    echo exampleContainers ## {brightWhite, ...}
    echo exampleContainers.len ## 4
  template part1 =
    input = loadInput
    (names, colors, rules, dirContainers) = parse input
    echo allContainers(0.Color, dirContainers).len

nbText: "ok, now let's start to implement stuff one by one"

nbCode:
  ## I take advantage that names and colors are global
  proc `$`(c: Color): string = names[c.int]
  proc toColor(name: string): Color = colors[name]
  proc parseRule(s: string): Rule =
    var col: string
    let i = parseUntil(s, col, " bags contain ")
    result.col = toColor(col)
    #  012345678901234567890123456789
    # "light red bags contain 1 bright white bag, 2 muted yellow bags."
    let contents = parseUntil(s, col, '.', start=i + 1)
