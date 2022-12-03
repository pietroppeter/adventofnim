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

func toGames(inp: seq[string]): seq[(int, int)] =
  inp.mapIt((ord(it[0]) - ord('A'), ord(it[2]) - ord('X')))

let games = day.filename.lines.toSeq.toGames
echo games[0..2]

func score1(game: (int, int)): int =
  # win: you: 2 (scissors), other: 1 (paper) -> you - other = 1 -> + 1 mod 3 = 2 -> *3 = 6
  # draw: you - other = 0 -> + 1 mod 3 = 1 -> *3 = 3
  # lose: you: 0 (rock), other: 1 (paper) -> you - other = -1 -> + 1 mod 3 = 0 -> *3 = 0
  ((game[1] - game[0] + 4) mod 3)*3 + game[1] + 1 # outcome + what you play

func part1(games:seq[(int, int)]): int =
  sum games.mapIt(score1 it)

# 1 mistake (-1 mod 3 -> -1)
echo part1 games

#example 1
echo "A Y\nB X\nC Z".split("\n").toGames.part1 # ok 15
echo "A Y\nB X\nC Z".split("\n").toGames.mapIt(score1 it) # ok 8, 1, 6
# new example
echo "A Z\nB Y\nC X".split("\n").toGames.part1 
echo "A Z\nB Y\nC X".split("\n").toGames.mapIt(score1 it)

func score2(game: (int, int)): int =
  let you = (game[1] - 1 + game[0] + 3) mod 3
  # Y draw 1: same as game[0]
  # X lose 0: 1 less than game0
  #debugEcho (you, game[0]), score1 (game[0], you)
  score1 (game[0], you)
# 2 mistakes (inverted tuple + forgot parenthesis)

func part2(games: seq[(int, int)]): int = sum games.mapIt(score2 it)

#example 1
echo "A Y\nB X\nC Z".split("\n").toGames.part2 # ok 12
echo part2 games
