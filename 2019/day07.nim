import strutils, sequtils, strformat, math, sets, tables, strscans, options

let input = "2019/day07.txt".readFile.split(',').map(parseInt)

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

proc run(input: seq[int], inpVals: seq[int]): seq[int] =
  var
    program = input
    pos = 0
    opcode, par1, par2, par3, mode1, mode2, mode3, val1, val2, val3, jump: int
    iInpVals = 0
  while true:
    opcode = program[pos] mod 100
    mode1 = (program[pos] div 100) mod 10
    mode2 = (program[pos] div 1000) mod 10
    mode3 = (program[pos] div 10000) mod 10
    if mode3 == 1:
      raise newException(ValueError, "Immediate mode for 3rd parameter not supported")
    # echo fmt"pos: {pos}, program: {program[pos]} opcode: {opcode} mode1: {mode1} mode2: {mode2}"
    if opcode == opHalt:
      # echo "HALT"
      return result
    
    # echo fmt"pos: {pos}, opcode: {opcode}, first: {first}, second: {second}, store: {store}; program: {program}"
    case opcode:
      of opAdd:
        jump = 4
        # echo fmt"program: {program[pos ..< pos + jump]}"
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
        # echo fmt"  *opAdd* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        program[par3] = val1 + val2
      of opMul:
        jump = 4
        # echo fmt"program: {program[pos ..< pos + jump]}"
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
        # echo fmt"  *opMul* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        program[par3] = val1 * val2
      of opIn:
        jump = 2
        # echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        val1 = inpVals[iInpVals]
        inc iInpVals
        # echo "using input ", val1
        # echo fmt"  *opIn* par1: {par1}, val1: {val1}"
        program[par1] = val1
      of opOut:
        jump = 2
        # echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        # echo fmt"  *opOut* par1: {par1}, val1: {val1}"
        # echo "OUT: ", val1
        result.add val1
      of opJumpIfTrue:
        jump = 3
        # echo fmt"program: {program[pos ..< pos + jump]}"
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
        # echo fmt"  *opJumpIfTrue* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}"
        if val1 != 0:
          # echo "JUMP!"
          jump = 0
          pos = val2
      of opJumpIfFalse:
        jump = 3
        # echo fmt"program: {program[pos ..< pos + jump]}"
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
        # echo fmt"  *opJumpIfFalse* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}"
        if val1 == 0:
          # echo "JUMP!"
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
        # echo fmt"  *opLessThan* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
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
        # echo fmt"  *opIsEqual* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        if val1 == val2:
          program[par3] = 1
        else:
          program[par3] = 0
      else:
        raise newException(ValueError, "unknown opcode " & $program[pos])
    pos += jump

let test1 = @[3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]

proc genPhaseCombinations(phases: openArray[int]): seq[seq[int]] =
  if phases.len == 2:
    return @[@[phases[0], phases[1]], @[phases[1], phases[0]]]
  elif phases.len == 1:
    return @[@[phases[0]]]
  else:
    for p in phases:
      let leftPhases = phases.filterIt(it != p)
      for s in leftPhases.genPhaseCombinations:
        result.add @[p] & s

let allPhaseCombinations = genPhaseCombinations([0, 1, 2, 3, 4])

# for c in allPhaseCombinations:
#   echo c

echo allPhaseCombinations.len

proc runCombination(input: seq[int], phases: seq[int]): int =
  var
    inpVals = @[0, 0]
    outVals: seq[int]
  for i, p in phases:
    # echo fmt"amplifier: {i}, phase: {p}"
    inpVals[0] = p
    outVals = input.run(inpVals)
    if outVals.len != 1:
      raise ValueError.newException("multiple outputs " & $outVals)
    inpVals[1] = outVals[0]
  return outVals[0]
    
echo test1.runCombination(@[4, 3, 2, 1, 0])

proc findMaxSignal(input: seq[int], phaseCombinations: seq[seq[int]]): int =
  var
    signal, maxSignal = 0
  for phases in phaseCombinations:
    # echo "try phase combination: ", phases
    signal = input.runCombination(phases)
    if signal > maxSignal:
      maxSignal = signal
      # echo "updated maxSignal ", maxSignal
  return maxSignal

echo "part1 (test1): ", test1.findMaxSignal(allPhaseCombinations)
echo "part1: ", input.findMaxSignal(allPhaseCombinations)

proc step(input: seq[int], pos: var int, inpSig: int): tuple[program: seq[int], pos, outSig, opCode: int] =
  var
    program = input
    opcode, par1, par2, par3, mode1, mode2, mode3, val1, val2, val3, jump: int
    inpConsumed = false
  while true:
    opcode = program[pos] mod 100
    mode1 = (program[pos] div 100) mod 10
    mode2 = (program[pos] div 1000) mod 10
    mode3 = (program[pos] div 10000) mod 10
    if mode3 == 1:
      raise newException(ValueError, "Immediate mode for 3rd parameter not supported")
    # echo fmt"pos: {pos}, program: {program[pos]} opcode: {opcode} mode1: {mode1} mode2: {mode2}"
    if opcode == opHalt:
      # echo "HALT"
      return (program, pos, inpSig, opHalt)
    
    # echo fmt"pos: {pos}, opcode: {opcode}, first: {first}, second: {second}, store: {store}; program: {program}"
    case opcode:
      of opAdd:
        jump = 4
        # echo fmt"program: {program[pos ..< pos + jump]}"
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
        # echo fmt"  *opAdd* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        program[par3] = val1 + val2
      of opMul:
        jump = 4
        # echo fmt"program: {program[pos ..< pos + jump]}"
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
        # echo fmt"  *opMul* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        program[par3] = val1 * val2
      of opIn:
        jump = 2
        # echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        if not inpConsumed:
          val1 = inpSig
          inpConsumed = true
        else:
          # echo "amp: ", program
          pos += jump
          return (program, pos, 0, opIn)
        # echo "using input ", val1
        # echo fmt"  *opIn* par1: {par1}, val1: {val1}"
        program[par1] = val1
      of opOut:
        jump = 2
        # echo fmt"program: {program[pos ..< pos + jump]}"
        par1 = program[pos + 1]
        if mode1 == 1:
          val1 = par1
        else:
          val1 = program[par1]
        # echo fmt"  *opOut* par1: {par1}, val1: {val1}"
        # echo "OUT: ", val1
        pos += jump
        return (program, pos, val1, opOut)
      of opJumpIfTrue:
        jump = 3
        # echo fmt"program: {program[pos ..< pos + jump]}"
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
        # echo fmt"  *opJumpIfTrue* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}"
        if val1 != 0:
          # echo "JUMP!"
          jump = 0
          pos = val2
      of opJumpIfFalse:
        jump = 3
        # echo fmt"program: {program[pos ..< pos + jump]}"
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
        # echo fmt"  *opJumpIfFalse* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}"
        if val1 == 0:
          # echo "JUMP!"
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
        # echo fmt"  *opLessThan* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
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
        # echo fmt"  *opIsEqual* par1: {par1}, par2: {par2}, val1: {val1}, val2: {val2}, par3: {par3}"
        if val1 == val2:
          program[par3] = 1
        else:
          program[par3] = 0
      else:
        raise newException(ValueError, "unknown opcode " & $program[pos])
    pos += jump

proc loopRunCombination(input: seq[int], phases: seq[int]): int =
  var
    amps: seq[seq[int]]
    pos: seq[int]
    ampOut, ampOp: int
  echo phases
  # amplifier initialization
  for i in 0 .. 4:
    amps.add input
    # echo "amp: ", amps[i]
    pos.add 0
    (amps[i], pos[i], ampOut, ampOp) = amps[i].step(pos[i], phases[i])
    doAssert ampOp == opIn # waiting for next input
    # echo fmt"(amp[{i}] <- {phases[i]}) -> (pos={pos[i]},out={ampOut},ampOp={ampOp})"
    echo fmt"amp[{i}]: ", amps[i]

  for t in 1 .. 100:
    echo "t: ", t
    for i in 0 .. 4:
      # echo ""
      # echo fmt"amp[i]: ", amps[i]
      # echo fmt"(amp[{i}] <- {ampOut})"
      (amps[i], pos[i], ampOut, ampOp) = amps[i].step(pos[i], ampOut)
      echo fmt"i: {i}; x={amps[i][26]}, y={amps[i][27]}, z={amps[i][28]}"
      # echo fmt"  -> (pos={pos[i]},out={ampOut},ampOp={ampOp})"
      if ampOp == opHalt:
        echo "halt: ", i
        return ampOut
      

let loopTest1 = @[3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]  

echo loopTest1.loopRunCombination @[9,8,7,6,5]
  