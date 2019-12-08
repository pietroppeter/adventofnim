import strutils, sequtils, strformat, math, sets, tables, strscans, options

when defined(test1):
  let input = "123456789012"
  const
    width = 3
    height = 2
    elems = width*height
elif defined(test2):
  let input = "0222112222120000"
  const
    width = 2
    height = 2
    elems = width*height
else:
  let input = "2019/day08.txt".readFile
  const
    width = 25
    height = 6
    elems = width*height# define: "test"


type
  Layer = array[elems, char]

proc toLayer(text: string): Layer =
  doAssert text.len == elems
  for i, c in text:
    result[i] = c

proc parseLayers(text: string): seq[Layer] =
  doAssert text.len mod elems == 0
  let numLayers = text.len div elems
  result = newSeqOfCap[Layer](numLayers)
  for i in 1 .. numLayers:
    result.add text[elems*(i - 1) ..< elems*i].toLayer

let layers = input.parseLayers
echo "num layers: ", layers.len

when defined(test1) or defined(test2):
  echo layers

when defined(part1):
  proc solve1(layers: seq[Layer]): int =
    var minZeroDigits = elems
    for l in layers:
      let c = l.toCountTable
      if c['0'] < minZeroDigits:
        minZeroDigits = c['0']
        result = c['1']*c['2']

  echo "part 1: ", solve1(layers)

proc parseImage(layers: seq[Layer]): Layer =
  result = layers[0]
  for i in 1 ..< layers.len:
    let l = layers[i]
    for j, c in l:
      if result[j] == '2':  # if it is transparent pick pixel from lower layer
        result[j] = c

proc toString(s: openArray[char]): string =
  result = s.len.newStringOfCap
  for c in s:
    result.add c

proc `$`(l: Layer): string =
  var rows = newSeqOfCap[string](height)
  for i in 1 .. height:
    rows.add l[width*(i - 1) ..< width*i].toString.replace("0", ".").replace("1", "*")
  rows.join("\n")

let image = layers.parseImage

echo "part 2:\n", $image  # HZCZU
