import strutils, parseutils, strformat, std/enumerate

type
  OpCode = enum
    opNop = "nop", opAcc = "acc", opJmp = "jmp"
  Instruction = tuple[op: OpCode, val: int]
  Program = object
    tr: int ## p.tr: pointer
    acc: int ## global register
    instrs: seq[Instruction]
  Trace = seq[seq[int]]

proc parse(text: string): seq[Instruction] =
  var
    op: OpCode
    val: int
  for i, line in enumerate(text.splitLines):
    try:
      op = parseEnum[OpCode](line[0 .. 2])
      discard parseInt(line[4 .. ^1], val)
      result.add (op, val)
    except:
      echo "ERROR parsing ", i, " ", line

let example = """nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6"""

var exp = Program(instrs: parse example)
echo exp

proc initTrace(p: Program): Trace =
  result.setlen(p.instrs.len)
  result[p.tr].add 1

# I will keep it global
var tr = initTrace(exp)
echo tr

template trace: bool =
  tr[p.tr].add(i + 1)
  tr[p.tr].len == 1

proc op(p: Program): OpCode = p.instrs[p.tr].op
proc val(p: Program): int = p.instrs[p.tr].val
proc endd(p: Program): bool = (p.tr == p.instrs.len)

proc exec(p: var Program): bool =
  let
    i = tr[p.tr][^1]
  case p.op:
    of opNop:
      inc p.tr
    of opAcc:
      p.acc += p.val
      inc p.tr
    of opJmp:
      inc p.tr, p.val
  if p.endd:
    return false
  trace

template echoo(p: Program) =
  echo p.op, " ", p.val, " | ", tr[p.tr]

when false:
  echoo(exp)
  while exec(exp): echoo(exp)
  echoo(exp)
  echo exp.acc # 5, ok

# part 2 fix (example first)
var q: Program
var k: int # last operation to test fixing
template fix(p: Program) =
  k = 0
  q = p
  while not q.endd:
    q = p
    while p.instrs[k].op == opAcc: inc k
    if p.instrs[k].op == opJmp: q.instrs[k].op = opNop
    elif p.instrs[k].op == opNop: q.instrs[k].op = opJmp
    else: echo "ERROR should not be here"
    echo "trying to fix instruction ", k
    tr = initTrace(q)
    #echo "q.acc: ", q.acc
    while exec(q): discard
    inc k
  echo "part2: ", q.acc

fix exp

echo "\n---\n"

let input = "2020/input08.txt".readFile
var inp = Program(instrs: parse input)
tr = initTrace(inp)
when false:
  while exec(inp): discard
  echo "part1: ", inp.acc

fix inp