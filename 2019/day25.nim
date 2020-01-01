import intcode, strutils

let p25 = "2019/day25.txt".readFile.parseProgram

var p: Program = p25
p.asciiCapable = true

let commands = """
south
take spool of cat6
west
take space heater
south
take shell
north
north
take weather machine
north
west
west
take whirled peas
east
east
south
west
south
east
take candy cane
west
south
take space law space brochure
north
north
east
south
east
east
south
take hypercube
south
south
"""

# get to security checkpoint with all "safe" objects
p.loadAsciiInput(commands)
discard p.run

# loop to find correct combination
var
  combination = 0
  message = ""

proc inputCommands(c: int): string =
  var
    i = 0
    c = c
  while i < 8:
    if c mod 2 == 1:
      result &= "take "
    else:
      result &= "drop "
    case i:
      of 0:
        result &= "candy cane"
      of 1:
        result &= "whirled peas"
      of 2:
        result &= "space law space brochure"
      of 3:
        result &= "weather machine"
      of 4:
        result &= "space heater"
      of 5:
        result &= "shell"
      of 6:
        result &= "hypercube"
      of 7:
        result &= "spool of cat6"
      else:
        raise ValueError.newException "should not get here!"
    result &= "\n"
    c = c div 2
    inc i
  result &= "east\n"

const failMessage = "you are ejected back to the checkpoint"

while combination < 256:
  echo "combination: ", combination
  p.loadAsciiInput(combination.inputCommands)
  discard p.run
  message = p.printAsciiOutput
  echo message
  if not message.contains(failMessage):
    break
  inc combination

# part 1: 4722720 (combination 105 -> candy cane, weather machine, shell, hypercube)

# interactive loop
while true:
  discard p.run
  echo p.printAsciiOutput
  if p.isWaitingForInput:
    let input = readLine(stdin)
    if input == "break":
      break
    p.loadAsciiInput(input & "\n")
  if p.isHalted:
    break
