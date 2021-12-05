import animu
include input04puzzleDraw

type
  Board = ref object
    size: int
    rows: seq[seq[int]]
    rowMarks: seq[seq[int]]
    colMarks: seq[seq[int]]

func newBoard(size=5): Board =
  result = Board()
  result.size = size
  result.rows = @[] # easier to add while parsing
  result.rowMarks = newSeqWith(len=size): newSeq[int]()
  result.colMarks = newSeqWith(len=size): newSeq[int]()

func getBoards(s: seq[string], size=5): seq[Board] =
  var
    board = newBoard(size=size)
    row: seq[int]
  for line in s:
    if line.strip == "":
      result.add board
      board = newBoard(size=size)
    else:
      row = line.strip.splitWhitespace.mapIt(parseInt(it))
      board.rows.add row
  result.add board    

let
  puzzleBoards = "2021/input04.txt".readFile.splitLines.getBoards

echo puzzleBoards.len

type Index = Table[int, seq[tuple[board, row, col: int]]]

func computeIndex(boards: seq[Board]): Index =
  result = initTable[int, seq[tuple[board, row, col: int]]]()
  for b, board in boards:
    for i, row in board.rows:
      for j, num in row:
        if num in result:
          result[num].add (b, i, j)
        else:
          result[num] = @[(b, i, j)]

let
  index = computeIndex(puzzleBoards)

proc mark(board: Board, num, i, j: int): bool =
  board.rowMarks[i].add num
  if board.rowMarks[i].len == board.size:
    result = true
  board.colMarks[j].add num
  if board.colMarks[j].len == board.size:
    result = true

func score(b: Board, winNum: int): int =
  for i, row in b.rows:
    for num in row:
      if num not_in b.rowMarks[i]:
        result += num
  debugEcho "sum of unmarked numbers: ", result
  result * winNum

proc solve(numbers: seq[int], boards:seq[Board], index: Index, part1=true): int =
  var
    win: bool
    winBoardNumbers: seq[int]
  for num in numbers:
    echo "draw: ", num
    for (b, i, j) in index[num]:
      win = boards[b].mark(num, i, j)
      if win:
        if part1:
          return score(boards[b], num)
        elif b not_in winBoardNumbers:
          winBoardNumbers.add b
          echo winBoardNumbers.len,  " wins: ", b, ", score: ",  score(boards[b], num)
          if winBoardNumbers.len == boards.len:
            return score(boards[b], num)

proc reset(boards: seq[Board]) =
  for board in boards:
    board.rowMarks = newSeqWith(len=board.size): newSeq[int]()
    board.colMarks = newSeqWith(len=board.size): newSeq[int]()

echo "part1: ", solve(puzzleDraw, puzzleBoards, index) #34506
reset puzzleBoards
echo "part2: ", solve(puzzleDraw, puzzleBoards, index, part1=false)
#42224 too high

let testDraw = @[7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1]
let testBoards = """
22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7""".splitLines.getBoards()

let testIndex = computeIndex(testBoards)

echo "------------------------test:"
echo "part1: ", solve(testDraw, testBoards, testIndex) #34506
reset testBoards
echo "part2: ", solve(testDraw, testBoards, testIndex, part1=false)
