import intcode, sequtils

let
  p7 = "2019/day07.txt".readFile.parseProgram
  test = "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0".parseProgram

proc permutations(s: openArray[int]): seq[seq[int]] =
  if s.len == 2:
    return @[@[s[0], s[1]], @[s[1], s[0]]]
  elif s.len == 1:
    return @[@[s[0]]]
  else:
    for p in s:
      let leftPhases = s.filterIt(it != p)
      for s in leftPhases.permutations:
        result.add @[p] & s

let allPhaseCombinations = permutations([0, 1, 2, 3, 4])

assert allPhaseCombinations.len == 120

proc runCombination(program: Program, phase: seq[int]): int =
  var
    p: seq[Program]
  for i, v in phase:
    p.add program
    p[i].inQ.push v
    p[i].inQ.push result
    discard p[i].run
    result = p[i].outQ.pop

proc runCombination2(program: Program, phase: seq[int]): int =
  var p: seq[Program]
  for v in phase:
    p.add program
    p[^1].inQ.push v
  
  while not p[^1].isHalted:
    for i in 0 ..< p.len:
      p[i].inQ.push result
      discard p[i].run
      result = p[i].outQ.pop
    
proc findMaxSignal(p: Program, phaseCombinations: seq[seq[int]], part2=false): int =
  var
    signal, maxSignal = 0
  for phases in phaseCombinations:
    # echo "try phase combination: ", phases
    if part2:
      signal = p.runCombination2(phases)
    else:
      signal = p.runCombination(phases)
    if signal > maxSignal:
      maxSignal = signal
      # echo "updated maxSignal ", maxSignal
  return maxSignal

assert test.findMaxSignal(allPhaseCombinations) == 65210
echo "part1: ", p7.findMaxSignal(allPhaseCombinations)

let test2 = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5".parseProgram

echo test2.runCombination2(@[9, 8, 7, 6, 5])
echo test2.findMaxSignal(@[5, 6, 7, 8, 9].permutations, part2=true)
echo "part2: ", p7.findMaxSignal(@[5, 6, 7, 8, 9].permutations, part2=true)