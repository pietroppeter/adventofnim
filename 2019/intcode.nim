import strutils, deques, sequtils, math, strformat

type IntType = int
let parseIntType: proc(x: string): IntType = parseInt
  
type
  Queue = Deque[IntType]
  Program = object
    mem: seq[IntType]
    pos: int
    rel: int
    inQ: Queue
    outQ: Queue
  OpCode = enum
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
  ParMode = enum
    parPos = 0
    parImm = 1
    parRel = 2
    parInvalidMode
  Parameter = object
    mode: ParMode
    pos: int
    val: IntType
  Instruction = object
    pos: int
    op: OpCode
    pars: int
    par: seq[Parameter]    

proc parseProgram(text: string): Program =
  result.mem = text.split(",").map parseIntType
  result.pos = 0
  result.rel = 0
  result.inQ = initDeque[IntType]()
  result.outQ = initDeque[IntType]()

proc push(q: var Queue, x: IntType) =
  q.addLast(x)

proc pop(q: var Queue): IntType =
  q.popFirst

proc invalidInstruction(p: Program): Instruction =
  result.op = opInvalid
  result.pos = p.pos
  result.pars = 0
  result.par.add Parameter(mode: parImm, val: p.mem[p.pos])

proc parseParameter(p: Program, i: int): Parameter =
  case (p.mem[p.pos] div 100*10^(i-1)) mod 10:
    of parPos.ord:
      result.mode = parPos
      result.pos = p.mem[p.pos + i]
    of parImm.ord:
      result.mode = parImm
      result.val = p.mem[p.pos + i]
    of parRel.ord:
      result.mode = parRel
      result.pos = p.mem[p.pos + i]
    else:
      result.mode = parInvalidMode

proc parseInstruction(p: Program): Instruction =
  var
    opcode: int
  result = Instruction(pos: p.pos)
  # process opcode
  opcode = p.mem[p.pos] mod 100
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
  if p.mem[p.pos] div 100*10^result.pars > 0:
    return p.invalidInstruction

proc `$`(p: Parameter): string =
  case p.mode:
    of parPos:
      return fmt"mem[{p.pos}]"
    of parImm:
      return fmt"{p.val}"
    of parRel:
      return fmt"mem[rel({p.pos:+})]"
    of parInvalidMode:
      return "invalidPar"

proc `$`(i: Instruction): string =
  fmt"{i.pos:4} {$i.op} " & i.par.map(`$`).join(", ")

proc jump(i: Instruction): int =
  i.pars + 1

proc `$`(p: Program): string =
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

when isMainModule:
  let testProg = (
    day2ex1: "1,9,10,3,2,3,11,0,99,30,40,50".parseProgram
  )
  echo $testProg.day2ex1