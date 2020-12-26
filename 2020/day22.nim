import animu
ddebug
import strutils, npeg, deques, sets, tables

type
  Deck = Deque[int]

let example = """Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10"""

proc parse(text: string): (Deck, Deck) =
  var i = 0
  for line in text.splitLines:
    if line.startsWith("Player"):
      continue
    elif line == "":
      i = 1
      continue
    if i == 0:
      result[0].addLast parseInt(line) # why can't I do result[i]?
    else:
      result[1].addLast parseInt(line)

var (deck1, deck2) = parse example
echo deck1
echo deck2

proc playRound(d1, d2: var Deck, verbose=false, game=0, round=0) =
  let
    card1 = d1.popFirst
    card2 = d2.popFirst
  if verbose:
    echo "Player 1's deck: ", d1
    echo "Player 2's deck: ", d2
    echo "Player 1 plays: ", card1
    echo "Player 2 plays: ", card2
  if card1 > card2:
    if verbose and game == 0: echo "Player 1 wins the round!"
    elif verbose and game > 0: echo "Player 1 wins round ", round, " of game ", game, "!"
    d1.addLast card1
    d1.addLast card2
  else:
    if verbose and game == 0: echo "Player 2 wins the round!"
    elif verbose and game > 0: echo "Player 2 wins round ", round, " of game ", game, "!"
    d2.addLast card2
    d2.addLast card1

proc play(d1, d2: var Deck, verbose=false, game=0) =
  var round = 1
  while d1.len > 0 and d2.len > 0:
    if verbose and game == 0: echo "-- Round ", round, " --"
    elif verbose and game > 0: echo "-- Round ", round, " (Game ", game, ") --"
    playRound(d1, d2, verbose=verbose)
  if verbose:
    echo "==Post-game results =="
    echo "Player 1's, deck:", d1
    echo "Player 2's, deck:", d2

play(deck1, deck2)

func score(d: Deck): int =
  for i in 0 ..< d.len: # deques do not have high
    result += (d.len - i)*d[i]

echo "part1, example: ", score(deck2)
assert score(deck2) == 306

let input = "2020/input22.txt".readFile
(deck1, deck2) = parse input
play(deck1, deck2)
echo "part1, input: ", score(deck1)
assert score(deck1) == 30138

# Part 2
func copy(d: Deck, c: int): Deck =
  var d = d
  for i in 1 .. c:
    result.addLast d.popFirst

# forward declaration needed
proc playRec(d1, d2: var Deck, verbose=false): int 

var games: Table[string, int]
template resetGames = games = initTable[string, int]()

proc print(d1, d2: Deck): string = $d1 & "\n" & $d2

proc playRecRound(d1, d2: var Deck, verbose=false, round=0, game=0): int =
  if verbose:
    echo "Player 1's deck: ", d1
    echo "Player 2's deck: ", d2
  let
    card1 = d1.popFirst
    card2 = d2.popFirst
  if verbose:
    echo "Player 1 plays: ", card1
    echo "Player 2 plays: ", card2
  if card1 <= d1.len and card2 <= d2.len:
    var
      deck1 = copy(d1, card1)
      deck2 = copy(d2, card2)
    if verbose: echo "Playing a sub-game to determine the winner...\n"
    dind
    let winner = playRec(deck1, deck2, verbose=verbose)
    dded
    if verbose: echo "...anyway, back to game ", game, "!"
    if winner == 2:
      if verbose: echo "Player 2 wins round ", round, " of game ", game, "!\n"
      d2.addLast card2
      d2.addLast card1
    else:
      if verbose: echo "Player 1 wins round ", round, " of game ", game, "!\n"
      d1.addLast card1
      d1.addLast card2
    return winner
  elif card1 > card2:
    if verbose: echo "Player 1 wins round ", round, " of game ", game, "!\n"
    d1.addLast card1
    d1.addLast card2
    return 1
  else:
    if verbose: echo "Player 2 wins round ", round, " of game ", game, "!\n"
    d2.addLast card2
    d2.addLast card1
    return 2

proc playRec(d1, d2: var Deck, verbose=false): int =
  var rounds = initHashSet[string]()
  var roundWinner: int
  let
    game = games.len + 1
    curGame = print(d1, d2)
  decho "Game ", game
  if game > 100000:
    echo "STOPPING recursion here"
    quit(1)
  if curGame in games and games[curGame] >= 0:
    decho "Game seen ", game
    return games[curGame]
  games[curGame] = -1
  if verbose: echo "=== Game ", game, " ===\n"
  var round = 1
  while d1.len > 0 and d2.len > 0:
    if verbose and game == 0: echo "-- Round ", round, " --"
    elif verbose and game > 0: echo "-- Round ", round, " (Game ", game, ") --"
    if print(d1, d2) in rounds:
      if verbose: echo "This round was played before, the overall game ends with a win of Player 1"
      decho "Game stops ", game
      games[curGame] = 0
      return 0
    rounds.incl print(d1, d2)
    roundWinner = playRecRound(d1, d2, verbose=verbose, game=game, round=round)
    #if roundWinner == 0:
      #d1.addLast d1.popFirst
      #d1.addLast d2.popFirst
      #return 1
    inc round
  decho "Game finished ", game
  games[curGame] = roundWinner
  if verbose and d1.len == 0:
    echo "The winner of game ", game, " is player 2!\n"
    if verbose and game == 1:
      echo "\n==Post-game results =="
      echo "Player 1's, deck:", d1
      echo "Player 2's, deck:", d2
    return 2
  elif verbose and d2.len == 0:
    echo "The winner of game ", game, " is player 1!\n"
    if verbose and game == 1:
      echo "\n==Post-game results =="
      echo "Player 1's, deck:", d1
      echo "Player 2's, deck:", d2
    return 1
  return roundWinner

echo "\n---\npart 2, example"
(deck1, deck2) = parse example
var winner = playRec(deck1, deck2, verbose=false)
template scores =
  if winner <= 1:
    echo "Player 1 wins"
    echo score(deck1)
  else:
    echo "Player 2 wins"
    echo score(deck2)
scores

echo "\npart2, small recursive example"
resetGames
(deck1, deck2) = parse """Player 1:
43
19

Player 2:
2
29
14"""
winner = playRec(deck1, deck2)

echo "\n---\n"
resetGames
(deck1, deck2) = parse input
when true:
  winner = playRec(deck1, deck2, verbose=false)
  scores
# 7708 too low
# 9018 too low
# 9863 wrong and no clue about low or high
# having issues about final score!
# 34705 wrong
# 31393 wrong
# 31587 correct!