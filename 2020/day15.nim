import tables, times

template upd =
  if last notin spoken:
    spoken[last] = turn
  elif last notin spokenAgain:
    spokenAgain[last] = turn
  else:
    spoken[last] = spokenAgain[last]
    spokenAgain[last] = turn

var nTurns = 2020

proc play(numbers: openarray[int]): int =
  var
    spoken = initTable[int, int]()
    spokenAgain = initTable[int, int]()
    last: int
  for turn in 1 .. nTurns:
    #echo "turn: ", turn
    if turn <= numbers.len:
      last = numbers[turn - 1]
      spoken[last] = turn
      #echo "  starting number, I speak ", last
    elif last in spoken and last notIn spokenAgain:
      #echo "  ", last, " is first time spoken, I speak 0"
      last = 0
      upd
    elif last in spoken and last in spokenAgain:
      #echo "  ", last, " was spoken in ",spoken[last], " and in ", spokenAgain[last]
      last = spokenAgain[last] - spoken[last]
      #echo "  I say ", last
      upd
    else:
      #echo "  ERROR I should not be her"
      return -1
  last

echo play [0,3,6]  ## 436
echo play [1, 3, 2]  ## 1
echo play [2, 1, 3]  ## 10
echo play [1, 2, 3]  ## 27
echo play [2, 3, 1]  ## 78
echo play [3, 2, 1]  ## 438
echo play [3, 1, 2]  ## 1836

echo "part 1: ", play [15,5,1,4,7,0] ## 1259

nTurns = 30_000_000

echo play [0,3,6]  ## 175594
echo play [1, 3, 2]  ## 2578
echo play [2, 1, 3]  ## 3544142
echo play [1, 2, 3]  ## 261214
echo play [2, 3, 1]  ## 6895259
echo play [3, 2, 1]  ## 18
echo play [3, 1, 2]  ## 362

let start = now()
echo "part 2: ", play [15,5,1,4,7,0] ## 689
echo "part 2 completed in ", now() - start
