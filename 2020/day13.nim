import nimib, animu, nimoji

nbInit
nbText: """## 2020, day 13: Shuttle Search :mag: :rocket:

Today was another mathematical day and the main character was the
[Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem) (CRT from now on).

Even though the day was rather straightforward for everyone which was able to recall that,
I find still very nice the fact that people could (and did) come up with very good solutions
without knowing about CRT. In particular most people who did solved the problem without knowing about CRT
did implement a very nice method to find solutions,
[search by sieving](https://en.wikipedia.org/wiki/Chinese_remainder_theorem#Search_by_sieving).

The CRT did click from me rightaway, so I did decide not to look for existing implementation
and decided to use the coefficient given by Bézout's identity, that can be computed with
[Extended Euclidean Algorithm](https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm).

I also knew beforehand that I might run into overflow issues and I might need to use
[bigints](https://github.com/def-/nim-bigints). I decided to first implement with standard `int`s and only
later upgrade to bigints if needed.

In the end I found out that the solution was below `int.high` but my specific methods using Bézout's coefficients
did ran into an overflow, so I just applied a quick patch without changing proc's signature.

In the end I think that the solution with the sieve is the most elegant and practical, since it would not need this.
""".emojize

nbCode:
  import strutils, sequtils
  import sugar

nbText: """part 1 was rather straightforward. I solved first for the example then wrapped that in a template
and used it also to solve it for the real input. No reading from file this, just parsing directly in source and also very basic parsing."""

nbCode:
  template solve1 =
    echo $buses ## why nimsuggest complains when no $?
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

gotTheStar

nbText: """### Part 2

As mentioned I need Extended Euclidean Algorithm. I went with a rather straightforward implementation.
I do not think my `if` and `return` here do conform to
[disruptek's tips and tricks](https://gist.github.com/disruptek/6d0cd6774d05adaa894db4deb646fc1d#miscellaneous).

I did have some debugging to do, and Wikipedia's worked example was very useful
"""
nbCode:
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
    when false:
      dump (r0, r1, r2)
      dump q1
      dump (s0, s1, s2)
      dump (t0, t1, t2)
    while r2 != 0:
      when false: debugecho "iterate:"
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
      when false:
        dump (r0, r1, r2)
        dump q1
        dump (s0, s1, s2)
        dump (t0, t1, t2)
    return if n1 > n2:
        (r1, s1, t1)
      else:
        (r1, t1, s1)

  echo extEuclid(240, 46) ## (2, -9, 47)

nbText: "my CRT solution algorithm did ran into overflows and I applied a patch inside using bigints"

nbCode:
  import bigints
  ## why can it have side effects?
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
      ## gives me overflow here but result is good for int64. let's just patch this part with bigints:
      let
        ba1 = a1.initBigInt
        bm2 = m2.initBigInt
        bn2 = n2.initBigInt
        ba2 = a2.initBigInt
        bm1 = m1.initBigInt
        bn1 = n1.initBigInt
        bres = (ba1*bm2*bn2 + ba2*bm1*bn1) mod (bn1*bn2)
      result = parseInt($bres)
      return result
    let
      a12 = crt(eqs[0..1])
      n12 = eqs[0].modulus*eqs[1].modulus
    #dump (n12, a12)
    var eqs = @[(n12, a12)] & eqs[2 .. eqs.high]
    return crt(eqs)

  dump crt(@[(3, 2), (5, 3), (7, 2)])  ## from sun-tzu: 23
  dump crt(@[(3, 0), (4, 3), (5, 4)])  ## wiki: 39

nbText: """Once I got both implementations right I applied to the example
(first manually parsed than I wrote the parse which also preprocesses stuff).
Of course here the good strategy is, while parsing, to keep track of position and add remainder to my data.
"""

nbCode:
  let
    ## buses = "7,13,x,x,59,x,31,19"
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

nbText: "to make sure at least the solution was below int.high I did print my expected upper bound. Ah, I did assume all modulus were coprime and I actually suspect they are all prime but did not check"
nbCode:
  let part2input = parse "37,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,433,x,x,x,x,x,x,x,23,x,x,x,x,x,x,x,x,17,x,19,x,x,x,x,x,x,x,x,x,29,x,593,x,x,x,x,x,x,x,x,x,x,x,x,13"


  echo part2input
  var n = 1
  for eq in part2input:
    n *= eq.modulus
    echo n
  echo int.high

  echo "part2: ", crt(part2input)

gotTheStar
nbSave