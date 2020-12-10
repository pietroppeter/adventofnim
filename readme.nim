import nimib, nimoji, strformat, os, strutils
when defined(regendoc):
  import osproc

nbInit

let
  docs = "https://pietroppeter.github.io/adventofnim/"
  repo = "https://github.com/pietroppeter/adventofnim/"

nbText: """
# :christmas_tree::crown: adventofnim

nim solutions for advent of code

I am starting to port all solutions to use [nimib](https://github.com/pietroppeter/nimib)

current content ([home](index.html)):""".emojize

var content = "* 2020\n"
for f in walkFiles("2020/*.html"):
  let g = f.replace("\\", "/")
  content &= &"  - [{g[5 .. ^1]}]({docs}{g})\n"
  when defined(regendoc):
    let cmd = "nim r " & changeFileExt(g, "nim")
    echo "exec: ", cmd
    if execCmd(cmd) != 0:
      echo "ERROR with: ", cmd


nbText: content

nbText: """
how to:

* generate README.md and index.html: `nim r readme index.html > README.md`
* regenerate also all html documents: `nim -d: regendoc r readme index.html > README.md`
"""

nbText: &"""
---

* [repo]({repo})
* [docs]({docs})
"""

nbSave