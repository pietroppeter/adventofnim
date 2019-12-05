import tables

proc nonDecreasing(p: string): bool =
  p[0] <= p[1] and p[1] <= p[2] and p[2] <= p[3] and p[3] <= p[4] and p[4] <= p[5]

proc hasDouble(p: string): bool =
  p[0] == p[1] or p[1] == p[2] or p[2] == p[3] or p[3] == p[4] or p[4] == p[5]

proc hasExactDouble(p: string): bool =
  let t = toCountTable(p)
  for k, v in t:
    if v == 2: return true
  
proc allCriteria(n: int): bool =
  let p = $n
  p.nonDecreasing and p.hasDouble
  
proc allCriteria2(n: int): bool =
  let p = $n
  p.nonDecreasing and p.hasExactDouble
  
var
  count = 0
  count2 = 0

for pwd in 265275 .. 781584:
  if pwd.allCriteria: inc count
  if pwd.allCriteria2: inc count2

echo count
echo count2