import strutils, sequtils, strformat, math, sets, tables, strscans

let input = "2019/day02.txt".readFile.split(',').map(parseInt)

echo input.len

const
  opAdd = 1
  opMul = 2
  opHalt = 99
  debug = true

let
  examples: seq[tuple[input, output: seq[int]]] = @[
    (@[1,9,10,3,2,3,11,0,99,30,40,50], @[3500,9,10,70,2,3,11,0,99,30,40,50]),
    (@[1,0,0,0,99], @[2,0,0,0,99]),
    (@[2,3,0,3,99], @[2,3,0,6,99]),
    (@[2,4,4,5,99,0], @[2,4,4,5,99,9801]),
    (@[1,1,1,4,99,5,6,0,99], @[30,1,1,4,2,5,6,0,99])
    ]


proc run(input: seq[int]): seq[int] =
  var
    program = input
    pos = 0
    opcode, first, second, store: int
  while true:
    opcode = program[pos]
    # echo fmt"pos: {pos}, opcode: {opcode}"
    if opcode == opHalt:
      # echo fmt"program: {program}"
      return program
    first = program[pos + 1]
    second = program[pos + 2]
    store = program[pos + 3]
    # echo fmt"pos: {pos}, opcode: {opcode}, first: {first}, second: {second}, store: {store}; program: {program}"
    case opcode:
      of opAdd:
        program[store] = program[first] + program[second]
      of opMul:
        program[store] = program[first] * program[second]
      else:
        raise newException(ValueError, "unknown opcode " & $program[pos])
    pos += 4

for example in examples:
  # echo example
  assert (run example.input) == example.output

# fix
proc run(input: seq[int]; noun, verb: int): seq[int] =
  var program = input
  program[1] = noun
  program[2] = verb
  run program

echo "part 1: ", input.run(12, 2)[0]
# 3562624
echo input.run(13, 5)[0]

const target = 19690720
echo "target: ", target

block outer:
  for noun in 0 .. 99:
    echo noun
    for verb in 0 .. 99:
      echo verb
      if input.run(noun, verb)[0] == target:
        echo noun*100 + verb
        break outer
