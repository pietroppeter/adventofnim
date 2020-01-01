import intcode, sugar

let p21 = "2019/day21.txt".readFile.parseProgram

# simple logic (expect to fail): jump if hole in front of you
let input0 = """
NOT A J
WALK
"""
echo p21.runAsciiCapable(input0)
# correctly fails

# better logic: jump if hole in one of next tiles AND NOT in fourth tile
let input1 = """
NOT A J
NOT B T
OR T J
NOT C T
OR T J
AND D J
WALK
"""
echo p21.runAsciiCapable(input1)
# succeded!

# part 2

# let's test how run works (using old logic)
let input2 = """
NOT A J
NOT B T
OR T J
NOT C T
OR T J
AND D J
RUN
"""
echo p21.runAsciiCapable(input2)

# extend jump logic to scan 4 tiles and 5th (do not expect to succeed)
let input3 = """
NOT A J
NOT B T
OR T J
NOT C T
OR T J
NOT D T
OR T J
AND E J
RUN
"""
echo p21.runAsciiCapable(input3)
# actually fails early on

let input4 = """
NOT A J
NOT B T
OR T J
NOT C T
OR T J
AND D J
AND E J
RUN
"""
echo p21.runAsciiCapable(input4)

let input5 = """
NOT A J
NOT B T
OR T J
NOT C T
OR T J
AND D J
AND E J
NOT A T
OR T J
RUN
"""
echo p21.runAsciiCapable(input5)
