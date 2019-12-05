import strutils, sequtils, strformat, math, sets, tables, strscans

let input = "2019/day05.txt".readFile.split(',').map(parseInt)

echo input.len

const
  opAdd = 1
  opMul = 2
  opIn = 3
  opOut = 4
  opJumpIfTrue = 5
  opJumpIfFalse = 6
  opLessThan = 7
  opIsEqual = 8
  opHalt = 99

proc run(input: seq[int], inpVal = 1): seq[int] =
  var
    program = input
    pos = 0
    opcode, par1, par2, par3, mode1, mode2, mode3, val1, val2, val3, jump: int
  while true:
    opcode = program[pos] mod 100
    mode1 = (program[pos] div 100) mod 10
    mode2 = (program[pos] div 1000) mod 10
    mode3 = (program[pos] div 10000) mod 10
    if mode3 == 1:
      raise newException(ValueError, "Immediate mode for 3rd parameter not supported")
    echo fmt"pos: {pos}, program: {program[pos]} opcode: {opcode} mode1: {mode1} mode2: {mode2}"
    if opcode == opHalt:
      echo "HALT"
      return result
    
    # echo fmt"pos: {pos}, opcode: {opcode}, first: {first}, second: {second}, store: {store}; program: {program}"
    case opcode:
      of opAdd:
        jump = 4
        echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        par2 = program[pos + 2]
        if mode2 == 1:
          val2 = par2
        else:
          val2 = program[par2]
        par3 = program[pos + 3]
        echo fmt"  *opAdd* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        program[par3] = val1 + val2
      of opMul:
        jump = 4
        echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        par2 = program[pos + 2]
        if mode2 == 1:
          val2 = par2
        else:
          val2 = program[par2]
        par3 = program[pos + 3]
        echo fmt"  *opMul* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        program[par3] = val1 * val2
      of opIn:
        jump = 2
        echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        val1 = inpVal
        echo fmt"  *opIn* par1: {par1}, val1: {val1}"
        program[par1] = val1
      of opOut:
        jump = 2
        echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        echo fmt"  *opOut* par1: {par1}, val1: {val1}"
        echo "OUT: ", val1
        result.add val1
      of opJumpIfTrue:
        jump = 3
        echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        par2 = program[pos + 2]
        if mode2 == 1:
          val2 = par2
        else:
          val2 = program[par2]
        echo fmt"  *opJumpIfTrue* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}"
        if val1 != 0:
          echo "JUMP!"
          jump = 0
          pos = val2
      of opJumpIfFalse:
        jump = 3
        echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        par2 = program[pos + 2]
        if mode2 == 1:
          val2 = par2
        else:
          val2 = program[par2]
        echo fmt"  *opJumpIfFalse* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}"
        if val1 == 0:
          echo "JUMP!"
          jump = 0
          pos = val2
      of opLessThan:
        jump = 4
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        par2 = program[pos + 2]
        if mode2 == 1:
          val2 = par2
        else:
          val2 = program[par2]
        par3 = program[pos + 3]
        echo fmt"  *opLessThan* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        if val1 < val2:
          program[par3] = 1
        else:
          program[par3] = 0
      of opIsEqual:
        jump = 4
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        par2 = program[pos + 2]
        if mode2 == 1:
          val2 = par2
        else:
          val2 = program[par2]
        par3 = program[pos + 3]
        echo fmt"  *opIsEqual* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        if val1 == val2:
          program[par3] = 1
        else:
          program[par3] = 0
      else:
        raise newException(ValueError, "unknown opcode " & $program[pos])
    pos += jump

echo input.run
echo input.run(inpVal=5)