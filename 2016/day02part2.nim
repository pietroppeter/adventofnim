import strutils

let input = "2016/day02.txt".readFile.splitLines

# Keypad
#     1
#   2 3 4
# 5 6 7 8 9
#   A B C
#     D

type
  Keypad = range[1 .. 13]
  Direction = enum
    up = -4, left = -1, right = +1, down = +4

proc move(button: var Keypad, instruction: Direction) =
  case instruction:
    of up:
      if button in [6, 7, 8, 10, 11, 12]:
        button = (button.int + up.ord).Keypad
      elif button in [3, 13]:
        button = (button.int + up.ord div 2).Keypad
    of left:
      if button in [3, 4, 6, 7, 8, 9, 11, 12]:
        button = (button.int + left.ord).Keypad
    of right:
      if button in [2, 3, 5, 6, 7, 8, 10, 11]:
        button = (button.int + right.ord).Keypad
    of down:
      if button in [2, 3, 4, 6, 7, 8]:
        button = (button.int + down.ord).Keypad
      elif button in [1, 11]:
        button = (button.int + down.ord div 2).Keypad

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

proc key(button: Keypad): string =
  case button:
    of 1 .. 9:
      $button
    else:
      $((button - 10 + 'A'.ord).char)

proc solve(instructions: seq[string]): string =
  var
    button: Keypad = 5
  for line in instructions:
    for c in line:
      # echo button, " ", c
      button.move c.toDirection
    # echo ""
    result &= button.key

# echo example.solve
assert example.solve == "5DB3"
echo "part 2: ", solve input