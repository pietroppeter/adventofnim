import npeg, strutils

# day 1: classic seq[int]
block day1:
  var s: seq[int]
  let p = peg "numbers":
    numbers <- +number
    number <- >+Digit * '\n':
      s.add parseInt($1)
  doAssert p.match("1\n2\n3\n").ok
  echo s
  if not p.match("4\n5\n6").ok:
    echo "make sure you have a newline at the end"
  echo s # even with a failing match, partial parsing was successful

block day2:
  let example = """1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
"""
  type
    Policy = object
      min, max: Natural
      ch: char
    Row = tuple[policy: Policy, password: string]
    Db = seq[Row]
  
  var db: Db
  var row: Row
  var policy: Policy
  let p = peg "rows":
    rows <- +row
    # why error?
    row <- >+Digit * '-' * >+Digit * ' ' * >Lower * ": " * >+Lower * '\n':
      policy.min = parseInt($1)
      policy.max = parseInt($2)
      policy.ch = ($3)[0]
      row = (policy, $4)
      db.add row
  if p.match(example).ok:
    for row in db:
      echo row
