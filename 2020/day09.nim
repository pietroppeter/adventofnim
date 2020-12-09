import nimib
import deques, sequtils, parseutils, strutils, intsets

nbInit
nbText: """# 2020, Day 9: Encoding Error

This turned out be to nice and easy but it does give satisfaction.

The strategy for first part is to use at the same time a `deque` and a `intset`
(*hey, I did not know there is a new [`packedset`](https://nim-lang.github.io/Nim/packedsets.html) that will generalize and replace
`intset`*).

The second part was rather straightforward with two nested for loops.

I would say anyway the main technique here is a wise use of `break` statement,
especially using named blocks.

But first things first, parsing the input this time is a simple one-liner:
"""

nbCode:
  proc parse(text: string): seq[int] = text.splitLines.map(parseInt)

  let
    input = parse "2020/input09.txt".readFile
    example = parse """35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576"""

  echo input.len
  echo example.len

# as usual when converting to nimib I fuck up the example...
nbText: "and I can pack the solution in a single proc:" 
nbCode:
  proc solve(s: seq[int], l: int): (int, int) =
    var
      d = initDeque[int]()
      p = initIntSet() ## p stands for packedsets, I tried to use it but I do not have it yet
      ## d and p are synchronized to contain same stuff
      n: int
    for i in 0 ..< l:
      d.addLast(s[i])
      p.incl s[i]
    block findInvalid:
      for i in l ..< s.len:
        n = s[i]
        block findPair:
          for m in d:
            if n != m and n - m in p: break findPair
          ## if I get here it means I have not found a sum!
          break findInvalid  ## n is answer for part1
        p.incl n
        p.excl d.popFirst
        d.addLast n
    ## part 2
    var
      nMin, nMax: int
      cumSum = s[0]
    block findSum:
      for k in 0 ..< s.len:
        cumSum = 0
        nMin = int.high
        nMax = 0
        for l in k ..< s.len:
          cumSum += s[l]
          if s[l] < nMin:
            nMin = s[l]
          if s[l] > nMax:
            nMax = s[l]
          if cumSum == n:
            break findSum
          if cumSum > n:
            break
    return (n, nMin + nMax)
  
  echo solve(example, 5) ## 127, 62
  echo solve(input, 25) ## 133015568, 16107959

nbSave