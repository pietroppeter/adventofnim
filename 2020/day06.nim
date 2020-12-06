import nimib, animu

let 
  input = "2020/input06.txt".readFile.replace("\c", "")
  example = """abc

a
b
c

ab
ac

a
a
a
a

b"""
# I went first with distinct but then incl failed (I needed an `==`)
# and I do not need HashSet in the end!
nbInit

nbText: "# --- Day 6: Custom Customs ---"

nbText: """
Needed some debugging to clear part2.
I like the fact that I am doing it with standard bitsets and not HashSet.
I did run into issues with carriage return (did not have it in example, have it in input)
"""

nbCode:
  type
    Answer = char
    AnsSet = set[char] 

  proc solve(text: string): (int, int) =
    var text = text & "\n\n"
    var
      groupAny: AnsSet
      groupEvery: AnsSet
      groupNew = true
      answers: AnsSet
      answer: Answer
      b: char # b is precedent of c
    for c in text:
      if c.isLowerAscii:
        answer = c.Answer
        answers.incl(answer)
      elif b == '\n':
          #echo "any: ", groupAny
          #echo "every: ", groupEvery
          result[0] += groupAny.len
          result[1] += groupEvery.len
          groupAny = {}.AnsSet
          groupEvery = {}.AnsSet
          groupNew = true
      elif c == '\n':
        groupAny.incl(answers)
        if groupNew:
          groupEvery = answers
          groupNew = false
        else:
          groupEvery = groupEvery * answers
        answers = {}.AnsSet
      else:
        # thanks to this I find out that input has "\c\n" as line ending
        echo "ERROR parsing " & c.repr
      b = c

  echo solve(example)
  echo solve(input)

gotTheStar
gotTheStar

nbSave
# chk solve(example), (11, 6) # this executes twice! bad!
# chk solve(input), (6437, 0)
