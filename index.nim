import nimib, nimoji, strformat, os, strutils
when defined(regendoc):
  import osproc

nbInit

nbDoc.title = ":christmas_tree::crown:".emojize

nbText: """
# :christmas_tree::crown: adventofnim

nim solutions for advent of code

WIP - updating solutions to [nimib](https://github.com/pietroppeter/nimib) 0.1

current content ([home](index.html)):""".emojize

var content = "* 2020\n"
for f in walkFiles("2020/*.html"):
  let g = f.replace("\\", "/")
  content &= &"  - [{g[5 .. ^1]}]({g})\n"
  when defined(regendoc):
    let cmd = "nim r " & changeFileExt(g, "nim")
    echo "exec: ", cmd
    if execCmd(cmd) != 0:
      echo "ERROR with: ", cmd


nbText: content

nbText: """
how to:

* generate README.md and index.html: `nim r index`
* regenerate also all html documents: `nim -d:regendoc r index`
""" # use also -d:release since day15 can take a while in debug mode

nbSave
nbDoc.filename = "README.md"
nbDoc.render = renderMark
nbSave