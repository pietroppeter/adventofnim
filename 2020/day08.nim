import nimib, animu
nbInit
nbText: "# 2020, Day 8: Handheld Halting"

nbText: """For a better solution than mine look at the solution shared
by fxn on the forum ([gist](https://gist.github.com/fxn/bbd90877bcd27581ee5f7720495c3c3f)).

I use a inelegant global trace (instead of an `intsets` of visted indices).
This solution is not that bad anyway.

Listing the imports (usually I hide them from the document).
"""
nbCode:
  import strutils, parseutils, strformat, std/enumerate

nbText: """rather standard types. I regretted very soon naming instructions
in the program as `instrs`, what a bad name!"""
nbCode:
  type
    OpCode = enum
      opNop = "nop", opAcc = "acc", opJmp = "jmp"
    Instruction = tuple[op: OpCode, val: int]
    Program = object
      tr: int ## p.tr: pointer
      acc: int ## global register
      instrs: seq[Instruction]
    Trace = seq[seq[int]]

nbText: "the parsing is clean, since opcodes are 3 letters do not even need scanf (enumerate is used for debugging)"
nbCode:
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

nbText: "testing the first lines of code on the example"
nbCode:
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

nbText: "as mentioned, I decided to go with a global trace variable for simplicty"
nbCode:
  proc initTrace(p: Program): Trace =
    result.setlen(p.instrs.len)
    result[p.tr].add 1

  # I will keep it global
  var tr = initTrace(exp)
  echo tr

  template trace: bool =
    tr[p.tr].add(i + 1)
    tr[p.tr].len == 1  ## somewhat cryptic. If you visited more than once length will be 2

nbText: "and here is the code for the execution of the program (single step)"
nbCode:
  proc op(p: Program): OpCode = p.instrs[p.tr].op
  proc val(p: Program): int = p.instrs[p.tr].val
  proc endd(p: Program): bool = (p.tr == p.instrs.len) ## end is keyword

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

nbText: """this was a template at the beginning
but I forgot strformat has known [limitations with template arguments](https://nim-lang.org/docs/strformat.html#limitations).

Of this I do like the name `echoo` (this is throwaway stuff for debugging purposes).
"""
nbCode:
  proc echoo(p: Program, tr: Trace) =
    echo p.op, " ", fmt"{p.val:3}", " | ", tr[p.tr]
    discard

  echoo(exp, tr)
  while exec(exp): echoo(exp, tr)
  echoo(exp, tr)

  echo "part1: ", exp.acc ## 5, ok
  exp.acc = 0 ## reset for part2

nbText: "part 2 appears first for the example. It is straightforward test of fixing iteratively all positions"
nbCode:
  # part 2 fix (example first)
  var q: Program
  var k: int # last operation to test fixing
  template fix(p: Program) =
    k = 0
    q = p
    while not q.endd:
      q = p
      if q.acc != 0: echo "ERROR it should be zero!"
      while p.instrs[k].op == opAcc: inc k
      if p.instrs[k].op == opJmp: q.instrs[k].op = opNop
      elif p.instrs[k].op == opNop: q.instrs[k].op = opJmp
      else: echo "ERROR should not be here"
      ##echo "trying to fix instruction ", k
      tr = initTrace(q)
      ##echo "q.acc: ", q.acc
      while exec(q): discard
      inc k
    echo "part2: ", q.acc

  fix exp ## 8, ok

nbText: "Finally let's collect the stars!"
nbCode:
  let input = "2020/input08.txt".readFile
  var inp = Program(instrs: parse input)
  tr = initTrace(inp)
  while exec(inp): discard
  echo "part1: ", inp.acc ## 1810
  tr = initTrace(inp)
  inp.acc = 0
  inp.tr = 0
  fix inp ## 969

nbText: "you know your solution is bad when trying to publish it you incur in all sorts of bugs..."
nbSave