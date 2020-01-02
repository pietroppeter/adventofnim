import strutils, strscans

when defined(test):
  echo "testing with small deck..."
  const deckSize = 10
else:
  const deckSize = 10007

type
  ShuffleTechnique = enum
    reverse, increment, cut
  ShuffleInstruction = tuple
    kind: ShuffleTechnique
    n: int
  ShuffleProcess = seq[ShuffleInstruction]
  Deck = array[deckSize, int]

proc initDeck(): Deck =
  for i, c in result:
    result[i] = i

when defined(test):
  let deckNew = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].Deck
  assert deckNew == initDeck()
else:
  let deckNew = initDeck()

proc dealNewStack(d: Deck): Deck =
  var j: int
  for i, c in d:
    j = deckSize - 1 - i
    result[j] = c

proc cutCards(d: Deck, n: int): Deck =
  var j: int
  for i, c in d:
    j = (i + deckSize - n) mod deckSize
    result[j] = c

proc dealWithIncrement(d: Deck, n: int): Deck =
  var j = 0
  for c in d:
    result[j] = c
    j = (j + n) mod deckSize

when defined(test):
  assert deckNew.dealNewStack == [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
  assert deckNew.cutCards(3) == [3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
  assert deckNew.cutCards(-4) == [6, 7, 8, 9, 0, 1, 2, 3, 4, 5]
  assert deckNew.dealWithIncrement(3) == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]
  echo "techniques reharsed correctly"

proc parseInstructions(text: string): ShuffleProcess =
  var n: int
  for line in text.splitLines:
    if line == "deal into new stack":
      result.add (reverse, 0).ShuffleInstruction
    elif scanf(line, "deal with increment $i", n):
      result.add (increment, n).ShuffleInstruction
    elif scanf(line, "cut $i", n):
      result.add (cut, n).ShuffleInstruction
    else:
      raise ValueError.newException "cannot understand instruction: " & line

proc shuffle(d: Deck, sp: ShuffleProcess): Deck =
  result = d
  for i in sp:
    case i.kind:
      of reverse:
        result = result.dealNewStack
      of increment:
        result = result.dealWithIncrement i.n
      of cut:
        result = result.cutCards i.n

when defined(test):
  let test = """
cut 6
deal with increment 7
deal into new stack"""

  assert deckNew.shuffle(test.parseInstructions) == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
  echo "simple shuffle process tested correctly"
else:
  let input = "2019/day22.txt".readFile.parseInstructions
  let deckShuffled = deckNew.shuffle input
  echo deckShuffled.find 2019
