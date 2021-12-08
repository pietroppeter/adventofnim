import animu, std / enumerate

type
  Pattern = set[char]
  Entry = tuple[signals: array[10, Pattern], digits: array[4, Pattern]]

# is there something in stdlib for this already?
func toPattern(s: string): Pattern =
  for c in s:
    result.incl c

func parse(text: string): seq[Entry] =
  var entry: Entry
  for line in text.splitLines.mapIt(it.split('|')):
    for i, signal in enumerate(line[0].strip.splitWhitespace):
      entry.signals[i] = signal.toPattern
    for i, digit in enumerate(line[1].strip.splitWhitespace):
      entry.digits[i] = digit.toPattern
    result.add entry

let puzzleInput = readFile("2021/input08.txt").parse

                      #1  4  7  8 
const uniqueLengths = [2, 4, 3, 7]

func part1(entries: seq[Entry]): int =
  for entry in entries:
    for digit in entry.digits:
      if digit.len in uniqueLengths:
        inc result

dump part1(puzzleInput)

func `$`(p: Pattern): string =
  p.toSeq.sorted.join("")

template checkFound(d: int) =
  if pattern[d].len == 0:
    raise ValueError.newException($d & "not found")
  dict[$pattern[d]] = d
  debugEcho "checkFound ", $d, " -> ", pattern[d]
  debugEcho "pattern: ", pattern
  debugEcho "dict: ", dict

func solve(entry: Entry): int =
  var
    pattern: array[0 .. 9, Pattern] # being explicit on index, equivalent to array[10, Pattern]
    dict: Table[string, int]
    fives: seq[Pattern] # patterns of length 5; one of 2, 3, 5
    sixes: seq[Pattern] # patterns of length 6; one of 6, 9, 0
  # unique signals
  for signal in entry.signals:
    case signal.len
    of 2:
      pattern[1] = signal
    of 3:
      pattern[7] = signal
    of 4:
      pattern[4] = signal
    of 7:
      pattern[8] = signal
    of 5:
      fives.add signal
    of 6:
      sixes.add signal
    else:
      raise ValueError.newException("invalid signal: " & $signal)
  checkFound(1)
  checkFound(4)
  checkFound(7)
  checkFound(8)
  # 3 is the only five that contains 7
  for five in fives:
    if pattern[7] < five:
      pattern[3] = five
      break
  checkFound(3)
  # 9 is the only six that contains 3
  for six in sixes:
    if pattern[3] < six:
      pattern[9] = six
      break
  checkFound(9)
  # 5 is the only five that contains (3 - 7) + (7 - 1) + (9 - 3)
  let almostFive = (pattern[3] - pattern[7]) + (pattern[7] - pattern[1]) + (pattern[9] - pattern[3])
  for five in fives:
    if five > almostFive:
      pattern[5] = five
      break
  checkFound(5)
  # 2 is the remaining five
  for five in fives:
    if five != pattern[3] and five != pattern[5]:
      pattern[2] = five
      break
  checkFound(2)
  # 6 is the only six that contains 5
  for six in sixes:
    if pattern[5] < six:
      pattern[6] = six
      break
  checkFound(6)
  # 0 is the remaining six
  for six in sixes:
    if six != pattern[6] and six != pattern[9]:
      pattern[0] = six
  checkFound(0)

  for digit in entry.digits:
    if $digit not_in dict:
      debugEcho "entry: ", entry
      debugEcho "pattern: ", pattern
      debugEcho "dict: ", dict
      debugEcho "fives: ", fives
      debugEcho "sixes: ", sixes
      raise ValueError.newException($digit & " not found in dict")
  
  # now we translate to a four digit number
  template digit(i: int): int = dict[$entry.digits[i]]

  result = digit[0]*1000 + digit[1]*100 + digit[2]*10 + digit[3]
  debugEcho "****\nentry.digits: ", entry.digits
  debugEcho "result: ", result

func part2(entries: seq[Entry]): int =
  for entry in entries:
    debugEcho "-----------------------\nentry: ", entry
    result += solve entry

let testInput = """
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce""".parse

dump part2(testInput)
echo "====================="
#dump part2(puzzleInput)