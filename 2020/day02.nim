import nimib, animu

nbInit

nbText: "# --- Day 2: Password Philosophy ---"

nbCode:
  let example = """1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
"""

nbText: """from [original text](https://adventofcode.com/2020/day/2)

a list (your puzzle input) of _passwords_
(according to the corrupted database) and
_the corporate policy when that password was set_.

For example, suppose you have the following list:
"""

nbCode: echo example

nbText: """
Each line gives the password policy and then the password.
The password policy indicates the lowest and highest number of times
a given letter must appear for the password to be valid.
For example, 1-3 a means that the password must contain
a at least 1 time and at most 3 times.

In the above example, 2 passwords are valid.
The middle password, cdefg, is not;
it contains no instances of b, but needs at least 1.
The first and third passwords are valid:
  they contain one a or nine c,
  both within the limits of their respective policies.

_How many passwords are valid_ according to their policies?"""

nbText: """## structure the data

something I love about Nim (wrt to my usual language Python)
is that the first thing you do is structure your data (i.e. deciding types)
and that is solving half of the problem.
"""

nbCode:
  type
    Policy = object
      min, max: Natural
      ch: char
    Row = tuple[policy: Policy, password: string]
    Db = seq[Row]

nbText: """and also that helps in naming.
how do I call the parse function? well, _parse_!

Do I want to extract parsing for the first row?
easy and I do not have to pick a new name!
"""

nbCode:
  func parse(line: string): Row =
    var
      i, j: int
      s, t: string
    if not scanf(line, "$i-$i $w: $w", i, j, s, t):
      debugEcho "error while parsing: " & line
    if s.len != 1:
      debugEcho "error in s.len. s: ", s, "; line: ", line
    result.policy.min = i
    result.policy.max = j
    result.policy.ch = s[0]
    result.password = t

  proc parse(lines: seq[string]): Db =
    for i, line in lines:
      result.add parse(line)

nbText: """
Also I love the fact that strscans prevents me to learn regular expressions.

Let's see how parsing work on base example:
"""

nbCode:
  echo (parse example.strip.splitLines).join("\n")

nbText: """
ok, good. Now let's solve part1 (for this example)

## part 1
"""

nbCode:
  func isValid(r: Row): bool =
    var count: int
    for c in r.password:
      if c == r.policy.ch:
        inc count
    if count >= r.policy.min and count <= r.policy.max:
      true
    else:
      false

  func part1(input: string): int =
    for row in parse(input.strip.splitLines):
      if row.isValid: inc result
  
  echo part1 example
  assert example.part1 == 2

nbText: &"now it's time to get the {star}!"

nbCode:
  echo part1 "2020/input02.txt".readFile

nbText: "*ok, I did spend a bit of time debugging here, just to find out that I forgot to past content in file...*"

gotTheStar

nbText: "## --- Part 2 ---"

nbText: """from [original text](https://adventofcode.com/2020/day/2)

Each policy actually describes _two positions in the password_,
where 1 means the first character, 2 means the second character,
and so on. (Be careful; Toboggan Corporate Policies have no
concept of "index zero"!)
_Exactly one of these positions_ must contain the given letter.
Other occurrences of the letter are irrelevant
for the purposes of policy enforcement.
"""

nbCode:
  func isValid2(r: Row): bool =
    var count: int
    if r.password[r.policy.min - 1] == r.policy.ch:
      inc count
    if r.password[r.policy.max - 1] == r.policy.ch:
      inc count
    count == 1

  func part2(input: string): int =
    for row in parse(input.strip.splitLines):
      if row.isValid2: inc result
  
  echo "example: ": part2 example
  echo "part2: ": part2 "2020/input02.txt".readFile

gotTheStar

# You have completed Day 2!

nbSave