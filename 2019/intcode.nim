import strutils, deques, sequtils, math, strformat

type IntType = int  
let parseIntType: proc(x: string): IntType = parseInt
  
type
  Queue* = Deque[IntType]
  Program* = object
    mem*: seq[IntType]
    pos*: int
    rel*: int
    inQ*: Queue
    outQ*: Queue
  OpCode* = enum
    opAdd = (1, "add")
    opMul = "mul"
    opIn = "in"
    opOut = "out"
    opJumpIfTrue = "jit"
    opJumpIfFalse = "jif"
    opLessThan = "lt"
    opIsEqual = "eq"
    opAdjRelBase = "rel"
    opHalt = (99, "halt")
    opInvalid = "mem"
  ParMode* = enum
    parPos = 0
    parImm = 1
    parRel = 2
    parInvalidMode
  Parameter* = object
    mode: ParMode
    pos: int
    val: IntType
  Instruction* = object
    pos: int
    op: OpCode
    pars: int
    par: seq[Parameter]    

proc parseProgram*(text: string): Program =
  result.mem = text.split(",").map parseIntType
  result.pos = 0
  result.rel = 0
  result.inQ = initDeque[IntType]()
  result.outQ = initDeque[IntType]()

proc push*(q: var Queue, x: IntType) =
  q.addLast(x)

proc pop*(q: var Queue): IntType =
  q.popFirst

proc getMem*(p: var Program, pos: int): IntType =
  if pos >= p.mem.len:
    p.mem.setLen(pos + 1)
  p.mem[pos]

proc setMem*(p: var Program, pos: int, val: IntType) =
  if pos >= p.mem.len:
    p.mem.setLen(pos + 1)
  p.mem[pos] = val  
  
proc invalidInstruction*(p: Program): Instruction =
  result.op = opInvalid
  result.pos = p.pos
  result.pars = 0
  result.par.add Parameter(mode: parImm, val: p.mem[p.pos])

proc parseParameter*(p: var Program, i: int): Parameter =
  case ((p.getMem p.pos) div (100*10^(i-1))) mod 10:
    of parPos.ord:
      result.mode = parPos
      result.pos = p.getMem(p.pos + i)
    of parImm.ord:
      result.mode = parImm
      result.val = p.getMem(p.pos + i)
    of parRel.ord:
      result.mode = parRel
      result.pos = p.getMem(p.pos + i)
    else:
      result.mode = parInvalidMode

proc getVal*(p: Parameter, q: var Program): IntType =
  case p.mode:
    of parImm:
      return p.val
    of parPos:
      return q.getMem(p.pos)
    of parRel:
      return q.getMem(q.rel + p.pos)
    of parInvalidMode:
      raise ValueError.newException "Invalid parameter"

proc getPos*(p: Parameter, q: Program): int =
  case p.mode:
    of parImm, parInvalidMode:
      raise ValueError.newException "Invalid or Immediate parameter"
    of parPos:
      return p.pos
    of parRel:
      return q.rel + p.pos

proc parseInstruction*(p: var Program): Instruction =
  var
    opcode: int
  result = Instruction(pos: p.pos)
  # process opcode
  opcode = p.getMem(p.pos) mod 100
  case opcode:
    of opAdd.ord:
      result.op = opAdd
      result.pars = 3
    of opMul.ord:
      result.op = opMul
      result.pars = 3
    of opIn.ord:
      result.op = opIn
      result.pars = 1
    of opOut.ord:
      result.op = opOut
      result.pars = 1
    of opJumpIfTrue.ord:
      result.op = opJumpIfTrue
      result.pars = 2
    of opJumpIfFalse.ord:
      result.op = opJumpIfFalse
      result.pars = 2
    of opLessThan.ord:
      result.op = opLessThan
      result.pars = 3
    of opIsEqual.ord:
      result.op = opIsEqual
      result.pars = 3
    of opAdjRelBase.ord:
      result.op = opAdjRelBase
      result.pars = 1
    of opHalt.ord:
      result.op = opHalt
      result.pars = 0
    else:
      return p.invalidInstruction
    # process parameters
  for i in 1 .. result.pars:
    result.par.add p.parseParameter(i)
    if result.par[^1].mode == parInvalidMode:
      return p.invalidInstruction
  if p.getMem(p.pos) div (100*10^result.pars) > 0:
    return p.invalidInstruction

proc `$`*(p: Parameter): string =
  case p.mode:
    of parPos:
      return fmt"mem[{p.pos}]"
    of parImm:
      return fmt"{p.val}"
    of parRel:
      return fmt"mem[rel({p.pos:+})]"
    of parInvalidMode:
      return "invalidPar"

proc `$`*(i: Instruction): string =
  fmt"{i.pos:4} {$i.op} " & i.par.map(`$`).join(", ")

proc jump*(i: Instruction): int =
  i.pars + 1

proc `$`*(p: Program): string =
  var
    i: Instruction
    p = p
    halted = false
  p.pos = 0
  while p.pos < p.mem.len:
    if halted:
      i = p.invalidInstruction
    else:  
      i = p.parseInstruction
    result.add $i & "\n"
    p.pos += i.jump
    if i.op == opHalt:
      halted = true

proc exec*(p: var Program, i: Instruction, verbose = false): bool =
  # returns false if halted or waiting for input
  assert p.pos == i.pos
  if verbose: echo $i
  case i.op:
    of opAdd:
      p.setMem(i.par[2].getPos(p), i.par[0].getVal(p) + i.par[1].getVal(p))
      if verbose: echo fmt"p.mem[{i.par[2].getPos(p)}] <- {i.par[0].getVal(p)} + {i.par[1].getVal(p)} = {i.par[0].getVal(p) + i.par[1].getVal(p)}"
    of opMul:
      p.setMem(i.par[2].getPos(p), i.par[0].getVal(p) * i.par[1].getVal(p))
      if verbose: echo fmt"p.mem[{i.par[2].getPos(p)}] <- {i.par[0].getVal(p)} * {i.par[1].getVal(p)} = {i.par[0].getVal(p) * i.par[1].getVal(p)}"
    of opIn:
      try:
        p.setMem(i.par[0].getPos(p), p.inQ.pop)
        if verbose: echo fmt"p.mem[{i.par[0].getPos(p)}] <- {i.par[0].getVal(p)}"
      except IndexError:
        return false
    of opOut:
      p.outQ.push i.par[0].getVal(p)
      if verbose: echo fmt"p.mem[{i.par[0].getPos(p)}] -> {i.par[0].getVal(p)}"
    of opJumpIfTrue:
      if i.par[0].getVal(p) != 0:
        p.pos = i.par[1].getVal(p)
        if verbose: echo fmt"p.pos <- {i.par[1].getPos(p)}"
        return true
    of opJumpIfFalse:
      if i.par[0].getVal(p) == 0:
        p.pos = i.par[1].getVal(p)
        return true
    of opLessThan:
      if i.par[0].getVal(p) < i.par[1].getVal(p):
        p.setMem(i.par[2].getPos(p), 1)
      else:
        p.setMem(i.par[2].getPos(p), 0)
    of opIsEqual:
      if i.par[0].getVal(p) == i.par[1].getVal(p):
        p.setMem(i.par[2].getPos(p), 1)
      else:
        p.setMem(i.par[2].getPos(p), 0)
    of opAdjRelBase:
      p.rel += i.par[0].getVal(p)
    of opInvalid:
      raise ValueError.newException "Invalid instruction: " & $i
    of opHalt:
      return false
  p.pos += i.jump
  return true

proc step*(p: var Program, n = 1, verbose=false): int =
  var
    i: Instruction
    n = n
  if n <= 0:
    n = int.high
  for s in 1 .. n:
    i = p.parseInstruction
    if not p.exec(i, verbose):
      break
    inc result

proc run*(p: var Program, verbose=false): int =
  p.step 0, verbose

proc repr*(p: Program): string =
  result &= fmt"pos: {p.pos}, rel: {p.rel}" & "\n"
  result &= fmt"mem: {p.mem}" & "\n"
  result &= fmt"inQ: {p.inQ}" & "\n"
  result &= fmt"outQ: {p.outQ}"

when isMainModule:
  var p: Program
  let testProg = (
    day2ex1: "1,9,10,3,2,3,11,0,99,30,40,50".parseProgram,
    day9ex1: "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99".parseProgram,
    day9ex2: "1102,34915192,34915192,7,4,7,99,0".parseProgram,
    day9ex3: "104,1125899906842624,99".parseProgram
  )
  
  echo "\n\n*DAY2EX1*"
  p = testProg.day2ex1
  echo $p
  echo "n steps: ", p.run
  echo p.repr
  assert p.mem[0] == 3500

  echo "\n\n*DAY9EX1*"
  p = testProg.day9ex1
  echo $p
  echo "n steps: ", p.run
  echo p.repr
  assert p.outQ.toSeq == testProg.day9ex1.mem

  echo "\n\n*DAY9EX2*"
  p = testProg.day9ex2
  echo $p
  echo "n steps: ", p.run
  echo p.repr
  assert ($p.outQ.pop).len == 16

  echo "\n\n*DAY9EX3*"
  p = testProg.day9ex3
  echo $p
  echo "n steps: ", p.run
  echo p.repr
  assert p.outQ.pop == 1125899906842624
