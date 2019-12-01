import strutils

let input = "2016/day02.txt".readFile.splitLines

# Keypad
# 1 2 3
# 4 5 6
# 7 8 9

type
  Keypad = range[1 .. 9]
  Direction = enum
    up = -3, left = -1, right = +1, down = +3

proc move(button: var Keypad, instruction: Direction) =
  case instruction:
    of up:
      if button in 4 .. 9:
        button = (button.int + up.ord).Keypad
    of left:
      if button in [2, 3, 5, 6, 8, 9]:
        button = (button.int + left.ord).Keypad
    of right:
      if button in [1, 2, 4, 5, 7, 8]:
        button = (button.int + right.ord).Keypad
    of down:
      if button in 1 .. 6:
        button = (button.int + down.ord).Keypad

let example = """ULL
RRDDD
LURDL
UUUUD""".splitLines

proc toDirection(c: char): Direction =
  case c:
    of 'U':
      up
    of 'L':
      left
    of 'R':
      right
    of 'D':
      down
    else:
      raise newException(ValueError, $c & " not a valid direction")

proc solve(instructions: seq[string]): string =
  var
    button: Keypad = 5
  for line in instructions:
    for c in line:
      # echo button, " ", c
      button.move c.toDirection
    result &= $button

assert example.solve == "1985"
echo "part 1: ", solve input