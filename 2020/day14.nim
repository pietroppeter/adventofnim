import nimib, animu, nimoji

nbInit
nbText: """## 2020, Day 14: Docking Data :ship: :minidisc:

Today was an opportunity to learn more about [bitops](https://nim-lang.org/docs/bitops.html).
""".emojize

nbCode:
  import bitops, tables, algorithm, math, strscans, strutils

nbText: "For part 1 I first make sure I can parse the mask. `floating` field is a result of refactoring for part 2."
nbCode:
  type
    Mask = object
      ones: int
      zeros: int
      floating: seq[int]
    Memory = Table[int, int]
  var
    mem: Memory
    mask: Mask

  proc parseMask(text: string): Mask =
    for i, c in text.reversed:
      case c:
        of '0':
          result.zeros += 2^i
        of '1':
          result.ones += 2^i
        of 'X':
          result.floating.add i
        else:
          echo "ERROR unexpected character in mask string: ", i, " ", c

  func apply(n: int, m: Mask): int =
    result = n
    setMask[int](result, m.ones)
    clearMask[int](result, m.zeros)

  mask = parseMask "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"
  echo mask
  echo 11.apply(mask) ## 73
  echo 101.apply(mask) ## 

nbText: """Now let's parse full programming instructions with `startswith` and `scanf`.
I gotta say that I tend to forget the syntax of object variants (`case kind: T` sounds pretty special).
"""
nbCode:
  type
    Program = seq[Action] # Action can go after
    ActionKind = enum updateMask, writeMem # ActionKind apparently not
    Action = object
      case kind: ActionKind  # I tend to forget the syntax 
      of updateMask:
        mask: Mask
      of writeMem:
        address: int
        value: int

  proc parse(text: string): Program =
    var a: Action
    for line in text.splitLines:
      if line.startsWith("mask"):
        a.kind = updateMask
        #01234567
        #mask = X
        a.mask = parseMask line[7..line.high]
      elif line.startsWith("mem"):
        a.kind = writeMem
        if not scanf(line, "mem[$i] = $i", a.address, a.value):
          echo "ERROR parsing writeMem: ", line
      else:
        echo "ERROR parsing line: ", line
      result.add a

  let example = """mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0"""
  let exProg = parse example
  echo $exProg

nbText: "Last ingredient is the proc to run the Program on Cpu."
nbCode:
  type
    Cpu = object
      mask: Mask
      mem: Memory
  var cpu: Cpu

  template resetCpu =
    clear cpu.mem  ## no need to reset mask as it is update as first action in program

  proc run(cpu: var Cpu, p: Program) =
    for a in p:
      case a.kind:
        of updateMask:
          cpu.mask = a.mask
        of writeMem:
          cpu.mem[a.address] = a.value.apply(cpu.mask)

  cpu.run exProg
  echo cpu
  proc answer(cpu: Cpu): int =
    for v in cpu.mem.values:
      result += v

  echo answer cpu

  resetCpu
  let inProg = parse "2020/input14.txt".readFile
  cpu.run inProg
  echo answer cpu

gotTheStar

nbText: """for part 2:
* after refactoring mask code to parse floating bits (done above)
* `run2` proc below is straightforward
* `apply2` is the part that creates multiple addresses starting from a single address and a mask
* finally `zeroBits` is the key ingredient that generates all floating bits combinations.

At one point I did consider coding a recursive iterator, but apparently that is not possible,
see  [forum](https://forum.nim-lang.org/t/5697).
"""
nbCode:
  iterator zeroBits(s: seq[int]): seq[int] =
    var m: int
    var t:seq[int]
    for n in 0..<2^(s.len):
      m = n
      t = @[]
      for i in 0..s.high:
        if m mod 2 == 0:
          t.add s[i]
        m = m shr 1
      yield t

  for s in zeroBits(@[1, 3, 5]):
    echo s

  func apply2(a: int, m: Mask): seq[int] =
    var b = a
    setMask[int](b, m.ones)
    ## I ignore zeros part of the mask
    ## floating: loop over all possible combinations
    for zeroBits in zeroBits(m.floating):
      var c = b
      for i in m.floating:
        if i in zeroBits:
          c.clearBit(i)
        else:
          c.setBit(i)
      result.add c

  let exMask = parseMask("000000000000000000000000000000X1001X")
  echo 42.apply2(exMask)

nbText: "looks good. let's apply directly to input without bothering about the example"
nbCode:
  proc run2(cpu: var Cpu, p: Program) =
    for a in p:
      case a.kind:
        of updateMask:
          cpu.mask = a.mask
        of writeMem:
          for address in a.address.apply2(cpu.mask):
            cpu.mem[address] = a.value

  resetCpu
  cpu.run2 inProg
  echo answer cpu

gotTheStar
nbSave