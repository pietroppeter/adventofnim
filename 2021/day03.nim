#? replace(sub="e♭", by="dx")
import nimib, animu

nbInit(theme=useAdventOfNim)

nbText: """## Day 3: [Binary Diagnostic](https://adventofcode.com/2021/day/3) 👯🎛️

I had to catch a plane this morning and the puzzle unlocked
while getting onto the plane. Luckily I was able to solve part1 in the few
minutes from the moment I sat on the plane to the moment they asked us
to turn off the devices, so I could get also the text for part2 and had
plenty of time during flight to solve it.

Today is also the day in which I finally realize a dream I have been having
since last edition of Advent Of Code: I want to be able to _listen to a puzzle input_
and I want to do it using the genuinely bizarre and bizarrely ingenious library [paramidi]
by one of my favorite Nim authors:
[oakes] (who is also responsible for [vim_cubed],
which I think is the most starred Nim repository after Nim compiler).

In order to do that, I accidentally released [paramidib] (not a typo) library,
which is just two templates to have better access to paramidi through nimib.
You can now follow along reading my rather dull solution for today
or head directly for [Part 3: Whale Music 🐳🎶](#whale_music).

Enjoy [Advent of Nim](https://forum.nim-lang.org/t/8657)! 🎄👑

[paramidi]: https://github.com/paranim/paramidi
[oakes]: https://github.com/oakes
[vim_cubed]: https://github.com/oakes/vim_cubed
[paramidib]: https://pietroppeter.github.io/paramidib/

### Part 1

> The diagnostic report (your puzzle input) consists of a list of binary numbers which, when decoded properly, can tell you many useful things about the conditions of the submarine. The first parameter to check is the _power consumption_.
> 
> You need to use the binary numbers in the diagnostic report to generate two new binary numbers (called the _gamma rate_ and the _epsilon rate_). The power consumption can then be found by multiplying the gamma rate by the epsilon rate.
> 
> Each bit in the gamma rate can be determined by finding the _most common bit in the corresponding position_ of all numbers in the diagnostic report. For example, given the following diagnostic report:
"""

nbCode:
  let testInput = """
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010"""

nbText: """
> Considering only the first bit of each number, there are five 0 bits and seven 1 bits. Since the most common bit is 1, the first bit of the gamma rate is 1.
>
> The most common second bit of the numbers in the diagnostic report is 0, so the second bit of the gamma rate is 0.
>
> The most common value of the third, fourth, and fifth bits are 1, 1, and 0, respectively, and so the final three bits of the gamma rate are 110.
>
> So, the gamma rate is the binary number 10110, or _22_ in decimal.
>
> The epsilon rate is calculated in a similar way; rather than use the most common bit, the least common bit from each position is used. So, the epsilon rate is 01001, or _9_ in decimal. Multiplying the gamma rate (22) by the epsilon rate (9) produces the power consumption, _198_.
>
> Use the binary numbers in your diagnostic report to calculate the gamma rate and epsilon rate, then multiply them together. _What is the power consumption of the submarine?_

"""
nbCode:
  let
    testNums = testInput.splitLines.toSeq
    puzzleNums = "2021/input03.txt".lines.toSeq

nbCode:
  func getGamma(nums: seq[string]): int =
    var
      gamma = ""
      countOnes: int
    for i in 0 .. nums[0].high:
      countOnes = 0
      for num in nums:
        if num[i] == '1':
          inc countOnes
      if countOnes >= nums.len div 2:
        gamma.add '1'
      else:
        gamma.add '0'
    result = parseBinInt gamma

  dump testNums.getGamma
  dump puzzleNums.getGamma

gotTheStar

nbCode:
  func part1(nums: seq[string]): int =
    let
      gamma = getGamma(nums)
      # 2^5(=32) - 22 - 1 -> 9 
      epsilon = 2^len(nums[0]) - gamma
    return gamma*epsilon

  dump part1 testNums
  dump part1 puzzleNums

nbCode:
  func lifeSupport(nums: seq[string], oxy=true): int =
    var
      nums = nums  # idiomatic
      i = 0
      zeros, ones: seq[int]
    while nums.len > 1:
      zeros = @[]  # zeros, ones = @[] does not work
      ones = @[]
      for j, num in nums:
        if num[i] == '1':
          ones.add j
        else:
          zeros.add j
      #dump ones
      #dump zeros
      if oxy:
        if ones.len >= zeros.len:
          nums = collect:
            for j in ones:
              nums[j]
        else:
          nums = collect:
            for j in zeros:
              nums[j]
      else:
        if zeros.len <= ones.len:
          nums = collect:
            for j in zeros:
              nums[j]
        else:
          nums = collect:
            for j in ones:
              nums[j]
      inc i
      #debugEcho nums
    assert nums.len == 1
    return parseBinInt(nums[0])

  func part2(nums: seq[string]): int =
    lifeSupport(nums)*lifeSupport(nums, false)
  dump part2 testNums
  dump part2 puzzleNums

gotTheStar

# add an anchor
nbText: """### Part 3: <a name="whale_music">Whale Music 🐳🎶</a>

> on top of the odd creaking noises that the submarine has been making in its descent,
> you start to hear a more pleasant melody that vibrates all through the hull.
> By looking outside the small circular windows you realize that you are surrounded
> by [singing whales](https://www.nationalgeographic.com/magazine/graphics/here-is-how-whales-sing-from-yaps-to-fin-slaps-feature)!
>
> Having already completed your star collection for the day,
> you decide to dedicate the rest of the day (and night) to learn more about this songs.
>
> Luckily, the _library of the submarnim_ has a small booklet by one mysterious
> [Kaz Cohaes](https://sekao.net) entitled
> [paralipomena of phalenotragoùdia](https://it.wikipedia.org/wiki/Paralipomeni_della_Batracomiomachia)
> that promises through the [lost art of midi](https://github.com/oakes/ansiwave) to
> allow you to be able to communicate with the singing whales!
>
> You are definitely in luck today, since it appears that the key ingredient to make
> such a communication possible is a _diagnostic report_ like the one produced by your submarine!
> You also happen to have the
> latest version of terminal _N.I.M.I.B._ (Natural Inducer of Music for Interesting Balenas)
> which you will use to solve the exercises proposed by the booklet.
>
> The first chapter of PoP (short for Paralipomena of phalenotragoùdia) starts with the basic
> assumption of whale singing. Communication happen through _musical scales_ and
> the utmost expressiveness is reached through _alternating moments of music and moments of silence_.
> Your first exercise is to translate your test diagnostic report into music.
>
> _Each line of the report is the repetition of the same scale, with the zeros representing
> moments of silence, while when a _1_ is present the note must be emitted_.

We will use library [paramidi] to produce the music, but we import it as [paramidib] (not a typo).
This is a convenience thin layer that exposes two templates to save a paramidi score
to a wave file and then to expose such a wave file through an html audio control.

Since the test diagnostic report is made of strings of 5 digits we will use a
[pentatonic scale](https://en.wikipedia.org/wiki/Pentatonic_scale).
The primary way to write a paramidi music score is through a bizarre data structure
which is a rather freely constructed hierarchy of tuples.
If you find an instrument in the tuple, it means that what follows will be played
with that instrument, a tempo annotation sets the tempo, a ratio of integers sets the
length of next note, then finally come the notes which have the usual syntax through
letter of the alphabet (there are ways also to change octave and to write chromatic notes).
A letter _r_ denotes a moment of rest (silence).

For the first exercise we will encode manually the score.

[paramidi]: https://github.com/paranim/paramidi
[paramidib]: https://github.com/pietroppeter/paramidib
"""
nbCode:
  import paramidib
  saveMusic("2021/day03test.wav"):
    (piano,
      (tempo: 109), # allegretto
      1/5, 
    # A C D E G    
    # 0 0 1 0 0
      r,r,d,r,r,
    # 1 1 1 1 0
      a,c,d,e,r,
    # 1 0 1 1 0
      a,r,d,e,r,
    # 1 0 1 1 1
      a,r,d,e,g,
    # 1 0 1 0 1
      a,r,d,r,g,
    # 0 1 1 1 1
      r,c,d,e,g,
    # 0 0 1 1 1
      r,r,d,e,g,
    # 1 1 1 0 0
      a,c,d,r,r,
    # 1 0 0 0 0
      a,r,r,r,r,
    # 1 1 0 0 1
      a,c,r,r,g,
    # 0 0 0 1 0
      r,r,r,e,r,
    # 0 1 0 1 0
      r,c,r,e,r   
    )
nbAudio("2021/day03test.wav")

nbText: """
Good job on producing the first piece of music!

> The second chapter of PoP tells you that longer sequence of digits
> may represent [arpeggios](https://en.wiktionary.org/wiki/arpeggio) of scales
> going up and down
>
> The third chapter tells you that whale are apparently fond a [bop](https://en.wikipedia.org/wiki/Bebop)
> and they like the color [blue](https://en.wikipedia.org/wiki/Blue).

Since the puzzle input is made of sequences of 12 digits, we will use
a [blues scale](https://en.wikipedia.org/wiki/Blues_scale) which is made of 6 notes
and we will go up and down the scale with an arpeggio.

Here is how this scale sound:
"""
nbCode:
  # blues scale: A C D Eb E G
  saveMusic("2021/blues_scale.wav"):
    (altosax,
      (tempo: 234), 2/12,
      -a, c, d, e♭, e, g,
       a, g, e, e♭, d, c,
      -a, c, d, e♭, e, g,
       a, g, e, e♭, d, c,
      2/12, -a, 1/12, c, 2/12, d, 1/12, e♭, 2/12, e, 1/12, g,
      2/12,  a, 1/12, g, 2/12, e, 1/12, e♭, 2/12, d, 1/12, c,
      2/12, -a, 1/12, c, 2/12, d, 1/12, e♭, 2/12, e, 1/12, g,
      2/12,  a, 1/12, g, 2/12, e, 1/12, e♭, 2/12, d, 1/12, c,
    )
nbAudio("2021/blues_scale.wav")
nbText: """
Note that:
  - we pass from a straight ryhthm to [triplet swing](https://en.wikipedia.org/wiki/Swing_(jazz_performance_style))
  - the instrument is a sax alto and the tempo is the same of Charlie Bird's [Ornithology](https://getsongbpm.com/song/ornithology/MjKLP5) (_prestissimo_)
  - `-a` is used for a `a` one octave lower
  - `e♭` is actually substituted through a [source code filter](https://nim-lang.org/docs/filters.html) to `dx` which represents `d#`

Now let's try to see how this would look with the moments of silence on zeros.
We take the forst two lines of puzzle input to test how it sounds:
"""
nbCode:
  echo puzzleNums[0 .. 1]

nbCode:
  saveMusic("2021/day03puzzle_head.wav"):
    (altosax,
      (tempo: 234),
     #       1        1        1        1         1        1
      2/12, -a, 1/12, c, 2/12, d, 1/12, e♭, 2/12, e, 1/12, g,
     #       0        1        0        0         1        1
      2/12,  r, 1/12, g, 2/12, r, 1/12, r , 2/12, d, 1/12, c,

     #       1        1        0        0         1        1
      2/12, -a, 1/12, c, 2/12, r, 1/12, r , 2/12, e, 1/12, g,
     #       0        0        1        1         0        0
      2/12,  r, 1/12, r, 2/12, e, 1/12, e♭, 2/12, r, 1/12, r,
    )
nbAudio("2021/day03puzzle_head.wav")

nbText: """
A tuple is an immutable data structure and since Nim is strongly typed it
is not the most flexible tool to write a score at runtime.
Luckily paramidi offers another way to write scores using `json` variant objects.
"""
nbCode:
  import json
  let puzzleHead =
    %*["alto-sax", {"tempo": 234},
      2/12, "a-", 1/12, "c", 2/12, "d", 1/12, "d#", 2/12, "e", 1/12, "g",
      2/12,  "r", 1/12, "g", 2/12, "r", 1/12, "r" , 2/12, "d", 1/12, "c",
      2/12, "a-", 1/12, "c", 2/12, "r", 1/12, "r" , 2/12, "e", 1/12, "g",
      2/12,  "r", 1/12, "r", 2/12, "e", 1/12, "d#", 2/12, "r", 1/12, "r",
    ]
  saveMusic("2021/day03puzzle_head_alt.wav", puzzle_head)
nbAudio("2021/day03puzzle_head_alt.wav")
nbText: """
Note that:
  - instead of `altosax` we need to use `alto-sax`
  - instead of `-a` we use `a-`
  - instead of `dx` we use `d#`
In fact all this alternative syntax is the most natural one since it derives
from the C library that paramidi used to produce the sound.
See the list of available constants [here](https://github.com/paranim/paramidi/blob/master/src/paramidi/constants.nim).

Now we are ready to create the score starting from a list of inputs in an automatic way:
"""
nbCode:
  func getScore(nums: seq[string], denominator=12): JsonNode =
    const arpeggio = @["a-", "c", "d", "d#", "e", "g", "a", "g", "e", "d#", "d", "c"]
    result = %*["alto-sax", {"tempo": 234}]
    var
      beat = true
      i = 0
    for num in nums:
      for digit in num:
        if beat:
          result.add %(2/denominator)
        else:
          result.add %(1/denominator)
        if digit == '1':
          result.add %(arpeggio[i mod 12])
        else:
          result.add %"r"
        inc i
        beat = not beat
  
  saveMusic("2021/day03puzzle_head_longer.wav", getScore(puzzleNums[0 ..< 10]))
  saveMusic("2021/day03puzzle_head_faster.wav", getScore(puzzleNums[0 ..< 20], denominator=24))
nbAudio("2021/day03puzzle_head_longer.wav")
nbAudio("2021/day03puzzle_head_faster.wav")
nbText: """We can also decide that we want to hear stuff at double the velocity.

Finally, here is the full song (not really since it is too big for github):"""
nbCode:
  saveMusic("2021/day03puzzle.wav", getScore(puzzleNums[0 .. 400]))
  saveMusic("2021/day03puzzle_faster.wav", getScore(puzzleNums[0 .. 400], denominator=24))
nbAudio("2021/day03puzzle.wav")
nbAudio("2021/day03puzzle_faster.wav")

nbText: """
> you spend most of the night talking with whales through music,
> it is one of the _most magical nights of your advent of code adventures_.

Gotta be honest I did not expect the final music to be so good!
I used it as soundtrack in loop while I was finishing writing the blogpost.

What _a magical night with whale music and what a great Adventure Advent of Code_ is!
"""

nbSave

