import nimib, animu, nimoji

nbInit
nbText: """## 2020, Day 15: Rambunctious Recitation :fire: :performing_arts:

This Advent of code seems to be about presents:
* First present today: _rambunctious_ or "full of energy and difficult to control".
* Second present: [Van Eck's sequence](http://oeis.org/A181391),
see also the [Numberphile episode](https://www.numberphile.com/videos/van-eck-sequence)
* Third present: part 2 is just simple brute force.
* Is the fourth present going to be someone from Advent of Code discovering something
new about this interesting sequence?

Nothing much to say about the implementation. I had to debug a bit in order to get
part 1 straight. Part 2 took around 5 seconds on my machine.
""".emojize

nbCode:
  import tables, times

  template upd =  ## extracted since it is repeated twice
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
        #echo "  ERROR I should not be here"
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

gotTheStar

nbCode:
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

gotTheStar

nbSave