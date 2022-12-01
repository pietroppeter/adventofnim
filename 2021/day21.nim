import sugar

var
  turn = 0
  rolls = 0
  score1 = 0
  score2 = 0
  pos1 = 4
  pos2 = 8
  dice = 1
  answer = 0


func cycle(n: int): int = ((n - 1) mod 10) + 1

template play =
  rolls = 0
  for i in 1 .. 3:
    rolls += dice
    inc dice
    if dice == 101:
      dice = 1
  if turn mod 2 == 0:
    pos1 = cycle(pos1 + rolls)
    score1 += pos1
  else:
    pos2 = cycle(pos2 + rolls)
    score2 += pos2
  inc turn
  #dump turn
  #dump score1
  #dump score2


template win: bool =
  if score1 >= 1000:
    answer = turn*3 * score2
    true
  elif score2 >= 1000:
    answer = turn*3 * score1
    true
  else:
    false

while not win:
  play

dump turn
dump score1
dump score2
dump answer

turn = 0
dice = 1
score1 = 0
score2 = 0
pos1 = 4
pos2 = 5

while not win:
  play

dump turn
dump score1
dump score2
dump answer
