import npeg, strutils

let
  expr1 = "1 + 2 * 3 + 4 * 5 + 6"
  expr2 = "1 + (2 * 3) + (4 * (5 + 6))"
  ans2 = 51
  input = "2020/input18.txt".readFile

type
  TokenKind = enum
    tkInt, tkPlus = "+", tkProd = "*", tkParOpen = "(", tkParClose = ")"
  ExprToken = object
    case kind: TokenKind
      of tkInt:
        intVal: int
      else:
        opStr: string # I do not really need that
  Expression = seq[ExprToken]

proc parse(expression: string): Expression =
  var toks: seq[ExprToken]
  let p = peg("expr"):
    expr <- token * *(*' ' * token) * !1
    token <- intToken | opToken
    intToken <- >+Digit:
      toks.add ExprToken(kind: tkInt, intVal: parseInt($1))
    opToken <- >("+" | "*" | "(" | ")"):
      toks.add ExprToken(kind: parseEnum[TokenKind]($1), opStr: $1)
  if p.match(expression).ok:
    return toks
  else:
    echo "ERROR parsing ", expression

echo parse expr1
echo parse expr2
var expr: Expression
for line in input.splitLines:
  expr = parse line
  if expr.len == 0:
    echo "ERROR parsing: ", line

proc findMatchParClose(expr: Expression, start: int): int =
  var i = start
  var nparOpen = 0
  while i < expr.len:
    if expr[i].kind == tkParClose:
      if nparOpen == 0:
        return i
      else:
        dec nparOpen
    if expr[i].kind == tkParOpen:
      inc nparOpen
    inc i
  echo "ERROR could not find a matching close Par"

proc simplify(expr: Expression): Expression =
  ## simplify a longer expression into an expression of length 1 (tkInt)
  if expr.len <= 1:
    return expr
  if expr.len == 2:
    echo "ERROR I don't think an expression of two terms is valid: ", expr
    return expr
  # expr.len >= 3
  if expr[0].kind == tkParOpen:
    let i = findMatchParClose(expr, start=1)
    return simplify(simplify(expr[1..<i]) & expr[(i + 1)..expr.high])
  if expr[0].kind == tkInt and expr[1].kind == tkPlus and expr[2].kind == tkInt:
    let tk = ExprToken(kind: tkInt, intVal:expr[0].intVal + expr[2].intVal)
    if expr.len == 3:
      return @[tk]
    else:
      return simplify(tk & expr[3..expr.high])
  if expr[0].kind == tkInt and expr[1].kind == tkProd and expr[2].kind == tkInt:
    let tk = ExprToken(kind: tkInt, intVal:expr[0].intVal * expr[2].intVal)
    if expr.len == 3:
      return @[tk]
    else:
      return simplify(tk & expr[3..expr.high])
  if expr[0].kind == tkInt and expr[1].kind in [tkProd, tkPlus] and expr[2].kind == tkParOpen:
    let i = findMatchParClose(expr, start=3)
    return simplify(expr[0..1] & simplify(expr[3..<i]) & expr[(i + 1)..expr.high])
  echo "ERROR I do not think there are other valid expressions. first 3 terms of this one: ", expr[0..2]
  return expr

echo simplify(parse expr1)[0].intVal  #71
echo simplify(parse expr2)[0].intVal # 51

var part1: int
for line in input.splitLines:
  part1 += simplify(parse line)[0].intVal
echo part1


proc simplify2(expr: Expression): Expression =
  # different strategy:
  # - simplify stuff in parentheses
  # - simplify expressions without parentheses
  if expr.len <= 1:
    return expr
  var i = 0
  var j = -1
  while i < expr.len:
    if expr[i].kind == tkParOpen:
      j = i
    elif expr[i].kind == tkParClose and j > -1:
      return simplify2(expr[0..<j] & simplify2(expr[(j+1)..<i]) & expr[(i+1)..expr.high]) 
    inc i
  # if I get here I know I do not have parenthesis
  i = 0
  while i < expr.len:
    if expr[i].kind == tkPlus:
      let tk = ExprToken(kind:tkInt, intVal: expr[i - 1].intVal + expr[i + 1].intVal)
      return simplify2(expr[0..<(i-1)] & @[tk] & expr[(i+2)..expr.high])
    inc i
  # if I get here I know I only have products
  assert expr[0].kind == tkInt
  assert expr[1].kind == tkProd
  assert expr[2].kind == tkInt
  let tk = ExprToken(kind:tkInt, intVal: expr[0].intVal * expr[2].intVal)
  return simplify2(@[tk] & expr[3..expr.high])

echo simplify2(parse "1 + 2 * 3 + 4 * 5 + 6")[0].intVal # 231
echo simplify2(parse "1 + (2 * 3) + (4 * (5 + 6))")[0].intVal # 51
echo simplify2(parse "2 * 3 + (4 * 5)")[0].intVal # 46
echo simplify2(parse "5 + (8 * 3 + 9 + 3 * 4 * 3)")[0].intVal # 1445
echo simplify2(parse "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))")[0].intVal # 669060
echo simplify2(parse "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")[0].intVal # 23340

var part2: int
for line in input.splitLines:
  part2 += simplify2(parse line)[0].intVal
echo part2