import npeg, strutils, sequtils, macros
import animu
ddebug

let ex1 = """0: 1 2
1: "a"
2: 1 3 | 3 1
3: "b""""

let ex2 = """0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb"""

when false: # did not pursue this strategy since I am not that good at macros...

  let p1 = peg("r0"):
    r0 <- r1 * r2
    r1 <- "a"
    r2 <- (r1 * r3) | (r3 * r1)
    r3 <- "b"

  assert p1.match("aab").ok
  assert p1.match("aba").ok
  assert not p1.match("ab").ok
  assert not p1.match("aaa").ok
  assert not p1.match("baa").ok

  let p2 = peg("r0"):
    r0 <- r4 * r1 * r5
    r1 <- (r2 * r3) | (r3 * r2)
    r2 <- (r4 * r4) | (r5 * r5)
    r3 <- (r4 * r5) | (r5 * r4)
    r4 <- "a"
    r5 <- "b"

  assert p2.match("aaaabb").ok
  assert p2.match("aaabab").ok

  dumpTree:
    let p = peg("r0"):
      r0 <- r4 * r1 * r5
      r1 <- (r2 * r3) | (r3 * r2)
      r2 <- (r4 * r4) | (r5 * r5)
      r3 <- (r4 * r5) | (r5 * r4)
      r4 <- "a"
      r5 <- "b"

import tables
type
  RuleKind = enum
    rkStr, rkAnd, rkOr
  Rule = object
    case kind: RuleKind
    of rkStr: strVal: string
    of rkAnd: rIds: seq[int]
    of rkOr:
      aIds: seq[int]
      bIds: seq[int]
  Rules = Table[int, Rule]

#[ tried to at least parse with npeg, but not enough confidence with that
proc parse(text: string): Rules =
  var rules: Rules
  let p = peg("rules"):
    rules <- rule * +("\n" * rule) * !1
    rule <- (strRule | andRule | orRule) * "\n"
    strRule <- >+Digit * ": " * '"' * >+Alpha * '"':
      rules[$1] = Rule(id: $1, kind: rkStr, strVal: $2)
    andRule <- >+Digit * ": " * >+Digit * +(" " * >+Digit):
      # stopping here I do not know how to capture seq[string]
    orRule <- >+Digit * ": " * >+Digit * +(" " * >+Digit) * " | " * >+Digit * +(" " * >+Digit)

]#

import strscans

proc parseRule(input: string, ruleVal: var Rule, start: int): int =
  if '"' in input:
    assert input[start] == '"'
    assert input[^1] == '"'
    ruleVal = Rule(kind: rkStr, strVal: input[(start + 1) ..< input.high])
  elif '|' in input:
    let ab = input[start .. input.high].split(" | ")
    ruleVal = Rule(kind: rkOr, aIds: ab[0].split(" ").map(parseInt), bIds: ab[1].split(" ").map(parseInt))
  else:
    ruleVal = Rule(kind: rkAnd, rIds: input[start .. input.high].split(" ").map(parseInt))
  result = input.len - start

proc parse(text: string): (Rules, seq[string]) =
  var parsingRules = true
  for line in text.splitLines:
    if parsingRules:
      if line == "":
        parsingRules = false
        continue
      var id: int
      var rule: Rule
      if scanf(line, "$i: ${parseRule}", id, rule):
        result[0][id] = rule
      else:
        echo "ERROR parsing line: ", line
    else:
      result[1].add line

let (rl2, in2) = parse ex2
for id, rl in rl2:
  echo id, ": ", rl
for inLine in in2:
  echo inLine

proc match(s: string, rs: Rules, id = 0, start = 0): int =
  decho "match id ", id, "; start ", start
  dind
  var i = start
  if i >= s.len:
    decho "i >= s.len, i: ", i, "; s.len: ", s.len
    dded
    # I hit here in part2. I tested returning 0 and s.len (same results)
    return 0
  case rs[id].kind:
    of rkStr:
      decho "rkStr: ", rs[id].strVal
      if s[i .. s.high].startsWith(rs[id].strVal):
        decho "OK"
        dded
        return rs[id].strVal.len
      else:
        decho "NOPE"
        dded
        return 0
    of rkAnd:
      decho "rkAnd: ", rs[id].rIds
      for rid in rs[id].rIds:
        decho "rid: ", rid
        let j = match(s, rs, id = rid, start = i)
        if j > 0:
          i = i + j
        else:
          decho "NOPE"
          dded
          return 0
      decho "OK"
      dded
      return i - start
    of rkOr:
      decho "rkOr. aIds: ", rs[id].aIds
      block matchA:
        for rid in rs[id].aIds:
          decho "rid: ", rid
          let j = match(s, rs, id = rid, start = i)
          if j > 0:
            i = i + j
          else:
            decho "A: NOPE"
            break matchA
        decho "A: OK"
        dded
        return i - start
      decho "rkOr. bIds: ", rs[id].bIds
      i = start
      for rid in rs[id].bIds:
        decho "rid: ", rid
        let j = match(s, rs, id = rid, start = i)
        if j > 0:
          i = i + j
        else:
          decho "B: NOPE"
          dded
          return 0
      decho "B: OK"
      dded
      return i - start

proc matchOk(s: string, rs: Rules): bool =
  decho "matching ", s, " of len ", s.len
  dind
  let matchLen = match(s, rs)
  decho "matchLen: ", matchLen
  dded
  matchLen == s.len

for s in in2:
  if matchOk(s, rl2):
    echo s, ": OK"
  else:
    echo s, ": NOPE"

var input = "2020/input19.txt".readFile
var (inpRules, inpLines) = parse input
echo inpRules.len

var part1 = 0
var i = 0
when false:
  for s in input.splitLines:
    if i <= inpRules.len:
      inc i
      continue
    inc i
    if matchOk(s, inpRules):
      inc part1

  echo "part1: ", part1

# example of part2
let example2 = """42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba"""
var (ex2Rules, ex2Lines) = parse example2
echo ex2Rules.len

part1 = 0
i = 0
for s in example2.splitLines:
  if i <= ex2Rules.len:
    inc i
    continue
  inc i
  if matchOk(s, ex2Rules):
    echo "OK  : ", s
    inc part1
  else:
    echo "NOPE: ", s

echo "example 2 part1: ", part1

echo "\n---\n"

proc matchOk2(s: string, rs: Rules): bool =
  # 8: 42 | 42 8
  # 11: 42 31 | 42 11 31
  # 0: 8 11
  # example of matches
  # 42 42 31, 42 42 42 42 31, 42 42 42 31 31, 42 42 42 42 31 31 31
  # in practice it means you match at least 2 42s and at least one 31 at the end.
  # Any number of 42s is fine, a number of 31 following that is less than (num42s - 1) is fine.
  var
    matchLen: int
    start = 0
    match42 = 0
    match31 = 0
  decho "matching ", s, " of len ", s.len
  dind
  decho "matching rule 42"
  matchLen = match(s, rs, id=42, start=0)
  if matchLen == 0:
    return false
  decho "ok rule 42, required 1st"
  start += matchLen
  inc match42
  matchLen = match(s, rs, id=42, start=start)
  if matchLen == 0:
    return false
  decho "ok rule 42, required 2nd"
  while matchLen > 0:
    start = start + matchLen
    inc match42
    matchLen = match(s, rs, id=42, start=start)
    if matchLen > 0: decho "ok rule 42, optional"
  start = start + matchLen
  decho "start after matching rule 42: ", start
  decho "match42: ", match42
  matchLen = match(s, rs, id=31, start=start)
  if matchLen == 0:
    return false
  decho "ok rule 31"
  inc match31
  start = start + matchLen
  matchLen = match(s, rs, id=31, start=start)
  while matchLen > 0:
    decho "another match for rule 31"
    inc match31
    start += matchLen
    matchLen = match(s, rs, id=31, start=start)
  decho "start after matching rule 42: ", start
  decho "match31: ", match31
  if match31 > (match42 - 1):
    decho "too many rule 31s"
    return false
  if start != s.len:
    decho "start != s.len"
    return false
  decho "match OK"
  dded
  return true

var part2 = 0

#{.push "debug".}

i = 0
for s in example2.splitLines:
  if i <= ex2Rules.len:
    inc i
    continue
  inc i
  if matchOk2(s, ex2Rules):
    echo "OK  : ", s
    inc part2
  else:
    echo "NOPE: ", s
echo "example2 part2: ", part2

i = 0
part2 = 0
for s in input.splitLines:
  if i <= inpRules.len:
    inc i
    continue
  inc i
  if matchOk2(s, inpRules):
    echo "OK  : ", s
    inc part2
  else:
    echo "NOPE: ", s
echo "input part2: ", part2
# 313 too high
