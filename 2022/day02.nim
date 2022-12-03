import batteries, aoc22, nimib, p5
let day = Day(
  num: 2,
  title: "Rock Paper Scissors",
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
  func toGames(inp: seq[string]): seq[(int, int)] =
    inp.mapIt((ord(it[0]) - ord('A'), ord(it[2]) - ord('X')))

  let games = day.filename.lines.toSeq.toGames
  echo games[0..2]
nbText: "solving part 1"
nbCode:
  func score1(game: (int, int)): int =
    # win: you: 2 (scissors), other: 1 (paper) -> you - other = 1 -> + 1 mod 3 = 2 -> *3 = 6
    # draw: you - other = 0 -> + 1 mod 3 = 1 -> *3 = 3
    # lose: you: 0 (rock), other: 1 (paper) -> you - other = -1 -> + 1 mod 3 = 0 -> *3 = 0
    ((game[1] - game[0] + 4) mod 3)*3 + game[1] + 1 # outcome + what you play

  func part1(games:seq[(int, int)]): int =
    sum games.mapIt(score1 it)

  # 1 mistake (-1 mod 3 -> -1)
  echo part1 games
nbText: """
Notes:
  - assumed by mistake that `mod N` always maps to 0..(N-1), instead it can take negative values
  - also learned python's modulo operator `%` is different than nim's `mod`
  - python equivalent mod is available in math module as `floorMod`
  - both modulo operator are defined as remainders of integer division
    but nim uses `system.div` (rounds towards zero) while python's uses
    [`floorDiv`](https://nim-lang.org/docs/math.html#floorDiv,T,T) (rounds down)

These were the examples I used to debug:
"""
nbCode:
  #example 1
  echo "A Y\nB X\nC Z".split("\n").toGames.part1 # ok 15
  echo "A Y\nB X\nC Z".split("\n").toGames.mapIt(score1 it) # ok 8, 1, 6
  # new example
  echo "A Z\nB Y\nC X".split("\n").toGames.part1 
  echo "A Z\nB Y\nC X".split("\n").toGames.mapIt(score1 it)
nbText: "solving part2"
nbCode:
  func score2(game: (int, int)): int =
    let you = (game[1] - 1 + game[0] + 3) mod 3
    # Y draw 1: same as game[0]
    # X lose 0: 1 less than game0
    #debugEcho (you, game[0]), score1 (game[0], you)
    score1 (game[0], you)

  func part2(games: seq[(int, int)]): int = sum games.mapIt(score2 it)

  #example 1
  echo "A Y\nB X\nC Z".split("\n").toGames.part2 # ok 12
  echo part2 games
nbText: """Notes:
- first mistake I had to debug, I inverted you and game[0] when computing score
- second mistake: I initially forgot parentheses in you expression
"""
nbSave