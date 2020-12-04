import nimib, animu

nbInit

nbText: """# --- Day 4: Passport Processing ---

I came with such an ugly solution that now I really _have to learn regexs_ for good
"""

nbCode:
  type
    PassField = enum
      byr, iyr, eyr, hgt, hcl, ecl, pid, cid
    PassPort = Table[PassField, string]
    Input = distinct string # since I need parse twice
  
  let
    input = "2020/input04.txt".readFile.Input
    example = """ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in""".Input

  proc parse(line: string): seq[tuple[f:PassField, s: string]] =
    for s in line.split:
      if s == "": continue
      let t = s.split(':')
      result.add (parseEnum[PassField](t[0]), t[1])

  proc parse(batch: Input): seq[PassPort] =
    var p: PassPort
    p = initTable[PassField, string]()
    for line in batch.string.splitLines:
      if line.len == 0:
        result.add p
        p = initTable[PassField, string]()
      for v in line.strip.parse:
        p[v.f] = v.s
    result.add p
  
  proc isValid(p: PassPort): bool =
    p.len == 8 or (p.len == 7 and cid notIn p)

  proc countValid(s: seq[PassPort]): int =
    for p in s:
      if p.isValid:
        inc result

  let
    pass0 = example.parse
    pass1 = input.parse
  echo pass0.countValid
  echo pass1.countValid

gotTheStar

nbCode:
  const colors = "amb blu brn gry grn hzl oth".split()

  proc validHgt(s: string): bool =
    var num: BiggestInt
    if s.endsWith("cm"):
      parseBiggestInt(s[0 .. ^3], num) != 0 and num >= 150 and num <= 193
    elif s.endsWith("in"):
      parseBiggestInt(s[0 .. ^3], num) != 0 and num >= 59 and num <= 76
    else:
      false

  template myEcho(s: string) = discard #echo s

  proc isGood(p: PassPort): bool =
    if not p.isValid: return false
    var num: BiggestInt
    myEcho $p
    if parseBiggestInt(p[byr], num) != 4 or num < 1920 or num > 2002:
      myEcho "invalid p[byr] " & p[byr]
      return false
    myEcho "valid p[byr] " & p[byr]
    if parseBiggestInt(p[iyr], num) != 4 or num < 2010 or num > 2020:
      myEcho "invalid p[iyr] " & p[iyr]
      return false
    myEcho "valid p[iyr] " & p[iyr]
    if parseBiggestInt(p[eyr], num) != 4 or num < 2020 or num > 2030:
      myEcho "invalid p[eyr] " & p[eyr]
      return false
    myEcho "valid p[eyr] " & p[eyr]
    if p[ecl] notIn colors:
      myEcho "invalid p[ecl] " & p[ecl]
      return false
    myEcho "valid p[ecl] " & p[ecl]
    var color: string
    if not p[hcl].startsWith("#") or p[hcl].len != 7 or p[hcl].parseWhile(color, {'0' .. '9', 'a' .. 'f'}, start=1) != 6:
      myEcho "invalid p[hcl] " & p[hcl]
      return false
    myEcho "valid p[hcl] " & p[hcl]
    if not(p[hgt].validHgt):
      myEcho "invalid p[hgt] " & p[hgt]
      return false
    myEcho "valid p[hgt] " & p[hgt]
    var digits: string
    if p[pid].parseWhile(digits, {'0' .. '9'}) != 9:
      myEcho "invalid p[pid] " & p[pid]
      return false
    myEcho "valid p[pid] " & p[pid]
    myEcho "ALLGOOD"
    return true

  proc countGood(s: seq[PassPort]): int =
    for p in s:
      if p.isGood:
        inc result
  
  echo pass0.countGood
  echo pass1.countGood # 154: too high; 150 ok (wrong pid validation)

gotTheStar

nbSave
