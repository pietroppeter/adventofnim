let example = """abc

a
b
c

ab
ac

a
a
a
a

b""" & '\n'

import npeg
var n: int
let p = peg("groups"):
  groups <- *group
  group <- *answers * '\n':
    # seems to never reach here.. why?
    echo n
  answers <- >(*Lower) * '\n':
    echo $1
    inc n
  
echo p.match(example)
echo n # 15, expected less