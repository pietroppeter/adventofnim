import animu

func match(c, d: char): bool = abs(ord(c) - ord(d)) <= 2

dump match('(',')')
dump match('[',']')
dump match('{','}')
dump match('<','>')

func score(line: string): (int, seq[char]) =
  var
    queue: seq[char]
    d: char
  for i, c in line:
    case c
    of '(', '[', '{', '<':
      queue.add c
    of ')', ']', '}', '>':
      d = pop queue
      if not c.match d:
        debugEcho &"{line}({i})\n  Expected {d}, but found {c} instead."
        case c
        of ')':
          return (3, queue)
        of ']':
          return (57, queue)
        of '}':
          return (1197, queue)
        of '>':
          return (25137, queue)
        else:
          raise ValueError.newException &"{line}\n  ERR should not get here: " & c
    else:
      debugEcho "WARN invalid char (ignored): ", c
  return (0, queue)

func part1(text: string): int =
  var i = 0
  for line in text.splitLines:
    inc i
    debugEcho i
    result += score(line.strip)[0]

let
  testInput = """
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]"""
  puzzleInput = readFile("2021/input10.txt")

dump part1 testInput
dump part1 puzzleInput

func score2(c: char): int =
  case c
  of '(':
    1
  of '[':
    2
  of '{':
    3
  of '<':
    4
  else:
    raise ValueError.newException "not a valid char " & c

func score2(queue: seq[char]): int =
  for c in queue.reversed:
    let n = score2 c
    result = 5*result + n

func part2(text: string): int =
  var scores: seq[int]
  for line in text.splitLines:
    let (n, queue) = score(line)
    if n == 0:
      scores.add score2(queue)
  sort scores
  return scores[scores.len div 2]
dump part2 testInput
dump part2 puzzleInput
