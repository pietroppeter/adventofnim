import npeg, parseutils
## of course now I must use npeg 
type
  Content = tuple[qty: int, col: string]
  Rule = tuple
    col: string
    con: seq[Content]
var
  qty: int
  r: Rule
  s: string

let parser = peg("rule", r: Rule):
  rule <- >color * " bags contain " * contents * ".":
    r.col = $1
  color <- word * " " * word
  word <- +Lower
  contents <- (nothing | stuff)
  nothing <- "no other bags"
  stuff <- oneormore * (", " * oneormore)
  oneormore <- one | more
  one <- "1 " * >color * "bag":
    r.con.add (1, ($1))
  more <- >+Digit * " " * >color * "bags":
    if parseInt($1, qty) != len($1):
      echo "ERROR parsing integer: ", $1
    r.con.add (qty, ($2)).Content

s = "light red bags contain 1 bright white bag, 2 muted yellow bags."
echo parser.match(s, r) # (ok: false, matchLen: 37, matchMax: 37, cs: (capList: ...))
echo r # (col: "", con: @[])
# mmh, lots to learn
