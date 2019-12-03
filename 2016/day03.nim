import sequtils, strutils, strformat, sets, tables

proc mySplit(s: string): array[3, int] =
  [s[0 .. 4].strip.parseInt, s[5 .. 9].strip.parseInt, s[10 .. ^1].strip.parseInt]

let      #012345678901234
  text = "  785   28  287"

echo text.mySplit

let input = "2016/day03.txt".readFile.splitLines.mapIt(it.mySplit)

# echo input

proc isTriangle(a: array[3, int]): bool =
  a[0] + a[1] > a[2] and a[1] + a[2] > a[0] and a[2] + a[0] > a[1]

echo "part 1: ", input.filterIt(it.isTriangle).len

          #          111111 1111222222222233 3333333344444444
let       #0123456789012345 6789012345678901 2345678901234567
  text2 = "  101  201  301\n  102  202  302\n  103  203  303\n"

proc mySplit2(input: string): seq[array[3, int]] =
  var i = 0
  while (i + 3)*16 <= input.len:
    let s = input[i*16 ..< (i + 3)*16]
    result.add [s[0 .. 4].strip.parseInt, s[16 .. 20].strip.parseInt, s[32 .. 36].strip.parseInt]
    result.add [s[5 .. 9].strip.parseInt, s[21 .. 25].strip.parseInt, s[37 .. 41].strip.parseInt]
    result.add [s[10 .. 14].strip.parseInt, s[26 .. 30].strip.parseInt, s[42 .. 46].strip.parseInt]
    i += 3

echo text2.mySplit2

let input2 = "2016/day03.txt".readFile.mySplit2

echo input[0 ..< 6]
echo input2[0 ..< 6]
echo input2[^6 .. ^1]  # last 3 are not correct, we are missing 3!

echo "part 2: ", input2.filterIt(it.isTriangle).len + 3 # verified by hand that last 3 are possible


