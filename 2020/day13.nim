import strutils, sequtils
import sugar

template solve1 =
  echo $buses # why nimsuggest complains when no $?
  var
    id, wait, minWait: int
  minWait = int.high
  for bus in buses:
    wait = bus - (timestamp mod bus)
    echo bus, ": ", wait
    if wait < minWait:
      minWait = wait
      id = bus
  echo (id, minWait, id*minWait)

block example:
  let
    timestamp = 939
    buses = "7,13,x,x,59,x,31,19".replace(",x", "").split(",").map(parseInt)
  solve1
block part1:
  let
    timestamp = 1003055
    buses = "37,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,433,x,x,x,x,x,x,x,23,x,x,x,x,x,x,x,x,17,x,19,x,x,x,x,x,x,x,x,x,29,x,593,x,x,x,x,x,x,x,x,x,x,x,x,13".replace(",x", "").split(",").map(parseInt)
  solve1

echo "\n---part2---\n"

# second part asks me to implement solution for chinese remainder theorem
# https://en.wikipedia.org/wiki/Chinese_remainder_theorem#Existence_(constructive_proof)
# I will also need extended euclid.
# https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
# will I need bigints? depends on product of my buses if it is too big
type Eq = tuple[modulus, remainder: int]

func extEuclid(n1, n2: int): (int, int, int) =
  let (a,b) = if n1 > n2:
      (n1, n2)
    else:
      (n2, n1)
  var
    # intialize
    r0 = a
    r1 = b
    s0 = 1
    s1 = 0
    t0 = 0
    t1 = 1
    # iterate
    q1 = r0 div r1
    r2 = r0 - q1*r1 # = r0 mod r1
    s2 = s0 - q1*s1
    t2 = t0 - q1*t1
  #dump (r0, r1, r2)
  #dump q1
  #dump (s0, s1, s2)
  #dump (t0, t1, t2)
  while r2 != 0:
    #debugecho "iterate:"
    # shift
    r0 = r1
    r1 = r2
    s0 = s1
    s1 = s2
    t0 = t1
    t1 = t2
    # iterate
    q1 = r0 div r1
    r2 = r0 - q1*r1 # = r0 mod r1
    s2 = s0 - q1*s1
    t2 = t0 - q1*t1
    #dump (r0, r1, r2)
    #dump q1
    #dump (s0, s1, s2)
    #dump (t0, t1, t2)
  return if n1 > n2:
      (r1, s1, t1)
    else:
      (r1, t1, s1)

echo extEuclid(240, 46) ## (2, -9, 47)

import bigints
# why can it have side effects?
proc crt(eqs: seq[Eq]): int =
  if eqs.len == 1:
    return eqs[0].remainder
  if eqs.len == 2:
    #dump eqs
    let
      (n1, a1) = eqs[0]
      (n2, a2) = eqs[1]
      (gcd, m1, m2) = extEuclid(n1, n2)
    if gcd != 1:
      echo "ERROR n1, n2 not coprime: ", (n1, n2, gcd)
    #dump (gcd, m1, m2)
    # gives me overflow here but result is good for int64. maybe if I am just careful...
    let
      ba1 = a1.initBigInt
      bm2 = m2.initBigInt
      bn2 = n2.initBigInt
      ba2 = a2.initBigInt
      bm1 = m1.initBigInt
      bn1 = n1.initBigInt
      bres = (ba1*bm2*bn2 + ba2*bm1*bn1) mod (bn1*bn2)
    result = parseInt($bres)
    #result = (a1*m2*n2 + a2*m1*n1) mod (n1*n2)
    while result < 0:
      #echo "HEEEY", (result, n1, n2, n1*n2)
      result += n1*n2
    return result
  let
    a12 = crt(eqs[0..1])
    n12 = eqs[0].modulus*eqs[1].modulus
  #dump (n12, a12)
  var eqs = @[(n12, a12)] & eqs[2 .. eqs.high]
  return crt(eqs)

dump crt(@[(3, 2), (5, 3), (7, 2)])  ## from sun-tzu: 23
dump crt(@[(3, 0), (4, 3), (5, 4)])  ## wiki: 39

let
  # buses = "7,13,x,x,59,x,31,19"
  #example2 = @[(7, 0),(13, 1),(59, 4),(31, 6),(19, 7)]
  example2 = @[(7, 0),(13, 13 - 1),(59, 59 - 4),(31, 31 - 6),(19, 19 - 7)]
echo crt(example2) # 1068781

proc parse(text: string): seq[Eq] =
  var i = 0
  for n in text.split(","):
    if n != "x":
      result.add (parseInt(n), i)
    inc i
  for i in 1..result.high:
    result[i][1] = result[i][0] - result[i][1]

echo parse "7,13,x,x,59,x,31,19"
  #"7,13,x,x,59,x,31,19"

# over or underflow! need bigints!
#echo crt(parse "37,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,433,x,x,x,x,x,x,x,23,x,x,x,x,x,x,x,x,17,x,19,x,x,x,x,x,x,x,x,x,29,x,593,x,x,x,x,x,x,x,x,x,x,x,x,13")
let part2input = parse "37,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,433,x,x,x,x,x,x,x,23,x,x,x,x,x,x,x,x,17,x,19,x,x,x,x,x,x,x,x,x,29,x,593,x,x,x,x,x,x,x,x,x,x,x,x,13"
echo part2input
var n = 1
for eq in part2input:
  n *= eq.modulus
  echo n
echo int.high

echo "part2: ", crt(part2input)
