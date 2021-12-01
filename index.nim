import nimib, nimoji, strformat, os, strutils, animu, tables
when defined(regendoc):
  import osproc

nbInit(theme=useAdventOfNim)

nbDoc.title = ":christmas_tree::crown:".emojize

nbText: """
# :christmas_tree::crown: adventofnim

nim solutions for advent of code ([home](index.html)):""".emojize

let years = ["2021", "2020"]
type Content = Table[string, seq[string]]
var content: Content

for year in years:
  content[year] = @[]
  for f in walkFiles(fmt"{year}/*.html"):
    let g = f.replace("\\", "/")
    content[year].add g
    when defined(regendoc):
      let cmd = "nim r -d:release " & changeFileExt(g, "nim")
      echo "exec: ", cmd
      if execCmd(cmd) != 0:
        echo "ERROR with: ", cmd

proc `$`(c: Content): string =
  for year in years:
    result &= &"* {year}\n"
    for page in content[year]:
      result &= &"  - [{page[5 .. ^1]}]({page})\n"

nbText: $content

nbText: """
how to:

* generate README.md and index.html: `nim r index`
* regenerate also all html documents: `nim -d:regendoc r index`
"""

nbSave
nbDoc.filename = "README.md"
nbDoc.render = renderMark
nbSave