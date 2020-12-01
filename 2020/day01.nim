import nimib

template gotTheStar = nbText: "The solution is correct! <em class=\"star\">*</em>"

nbInit

nbText : "# --- Day 1: Report Repair ---"

nbText: "## imports"

nbCode:
  include prelude
  import sequtils, algorithm

nbText: "## input"

nbCode:
  let input: seq[int] = toSeq("2020/input01.txt".lines).map(parseInt)
  echo input.len
  echo input[0 .. 10]
  echo input[^10 .. ^1]

nbText: "## -- Part 1 --"
nbText: """
solution to parse 1 does not necessarily even needs to parse the whole input.
this solution is correct also for the edge case 2010 + 2010"""

nbCode:
  var s, t: seq[int]  # t used in part 2
    
  for n in input:
    if n < 1010:
      t.add n
    if 2020 - n in s:
      echo "part 1: ", n*(2020 - n)
    s.add n

gotTheStar

nbText: "## -- Part 2 --"

nbCode:
  s.sort()
  t.sort()
  block outer:
    for i, n in s:
      for m in s[(i + 1) .. ^1]:
        for k in t:
          if n + m + k == 2020:
            echo "part 2: ", n*m*k
            break outer
          if n + m + k > 2020:
            break

gotTheStar

# TODO: fix how code elements look like when not a direct child of pre
# nbText: "the above solution is not necessarily correct since `k in t` could be one of `n` or `m`"

nbSave