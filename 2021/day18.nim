import animu, nimib

template nbNull(body: untyped) = body

nbInit
nbText: """
"""
nbCode:
  block:
    type
      Number = ref object
        height: int
        case isPair: bool
        of true:
          left, right: Number
        of false:
          value: int

  type
    Number = object
      values: seq[int]
      lefts: seq[seq[bool]] # heights[i] is len of lefts[i]

  func parse(text: string): Number =
    var
      left: seq[bool]
    for c in text:
      case c
      of '[':
        left.add true
      of '0' .. '9':
        result.values.add ord(c) - ord('0')
        result.lefts.add left
      of ',':
        left[^1] = false
      of ']':
        discard left.pop
      else:
        raise ValueError.newException &"invalid character: '{c}'"
  
  func `$`(n: Number): string =
    var left: seq[bool]
    for i in 0 .. n.values.high:
      if left.len < n.lefts[i].len:
        for _ in left.len ..< n.lefts[i].len:
          result.add '['
      elif left.len == n.lefts[i].len:
        assert left[^1] != n.lefts[i][^1]
        var count = 0
        for j in 1 .. left.len:
          if left[^j] != n.lefts[i][^j]:
            inc count
          else:
            break
        assert count >= 1
        result.add ']'.repeat(count - 1)
        result.add ','
        result.add '['.repeat(count - 1)
      else:
        for _ in n.lefts[i].len ..< left.len:
          result.add ']'
        result.add ','
      
      result.add $n.values[i]
      
      left = n.lefts[i]
    for _ in 0 ..< left.len:
      result.add ']'

  for line in """
[1,2]
[[1,2],3]
[9,[8,7]]
[[1,9],[8,5]]
[[[[1,2],[3,4]],[[5,6],[7,8]]],9]
[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]
[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]""".splitLines:
    echo line, " -> ", parse(line)
    echo parse(line).lefts

nbSave

