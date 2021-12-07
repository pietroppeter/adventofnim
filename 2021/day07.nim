#[
  - optimal point is for sure inside
  - for 
]#
import animu, nimib
nbInit(theme=useAdventOfNim)

# this and nbAudio should end up in nimib!
template nbVideo(mp4url: string) = nbText """
<video controls>
  <source src="""" & joinPath(nb.srcDirRel.string, mp4url) & """" type="video/mp4">
Your browser does not support the video element.
</video>
"""

nbText: """## Day 7: [The Treachery of Whales]
[The Treachery of Whales]: https://adventofcode.com/2021/day/7

Today was easier then past days and there is not much to
comment on puzzle solution. I did instead break my head to try and
get out a decent animation using [nanim] and I was able to
come out with something uing a celebrated technique in programming:
the _accumulation of wrong fixes_! More on that below.

[nanim]: https://github.com/EriKWDev/nanim

### Part 1

`minIndex` is returned as part of result to use it for visualization.
"""
nbCode:
  let
    puzzleInput = readFile("2021/input07.txt").strip.split(',').map(parseInt)
    testInput = @[16,1,2,0,4,2,7,1,2,14]

  echo len(puzzleInput)
  echo min(puzzleInput)
  echo max(puzzleInput)
nbCode:
  # assume min = 0
  func cost(crab: int, max: int): seq[int] =
    result = newSeqWith(len=max + 1): 0
    for i in 0 .. result.high:
      result[i] = abs(crab - i)

  func cost(crabs: seq[int]): seq[int] =
    let max = max(crabs)
    result = newSeqWith(len=max + 1): 0
    for crab in crabs:
      for i, c in cost(crab, max):
        result[i] += c

  func part1(crabs: seq[int]): (int, int) =
    let c = cost(crabs)
    (min(c), minIndex(c))

  let
    testResult = part1(testInput)
    puzzleResult = part1(puzzleInput)
  echo "part1(test): ", $testResult[0]
  echo "part1(puzzle): ", $puzzleResult[0]

gotTheStar

nbText: """### Part 2

Same as above but the single cost function for the crab is not aboslute value
but you need to remember Gauss's formula to sum up first n numbers. On that matter
I remember reading (possibly in Bühler's Biography) that the famous task by the teacher
was not about first 100 number but to sum the 100 numbers after a big number (e.g. 4097).
I cannot find any reference to this unfotunately.
"""
nbCode:
  func cost2(crab: int, max: int): seq[int] =
    result = newSeqWith(len=max + 1): 0
    for i in 0 .. result.high:
      let n = abs(crab - i)
      result[i] = n * (n + 1) div 2 

  func cost2(crabs: seq[int]): seq[int] =
    let max = max(crabs)
    result = newSeqWith(len=max + 1): 0
    for crab in crabs:
      for i, c in cost2(crab, max):
        result[i] += c

  func part2(crabs: seq[int]): (int, int) =
    let c = cost2(crabs)
    (min(c), minIndex(c))

  let
    testResult2 = part2(testInput)
    puzzleResult2 = part2(puzzleInput)
  echo "part2(test): ", $testResult2[0]
  echo "part2(puzzle): ", $puzzleResult2[0]

gotTheStar

nbText: """### Visualization: Crab Dance 🦀🕺

I will animate the crab dance using [nanim], a [manim] inspired library to produce animations.

[nanim]: https://github.com/EriKWDev/nanim
[manim]: https://github.com/3b1b/manim/

- I took my time picking _colors_: rust color is taken from [languist], crab color
  is the result of applying a color quantization technique based on k means clustering
  to a picture of [famous red crabs] (and the color quantization [library] is itself in rust);
  did you know that on mac there is a nice [Digital Color Meter] to find colors used in images?
- the way to create a video in nanim relies on command line options. In order to be able to
  have a more ergonomic way to generate videos and include them in nimib, I refactored
  the rendering apporach of nanim ([PR pending])

All seemed to go well, but I was not able to generate a canvas of the appropriate size
with correct position. It might be a bug ([Opened Issue]), or it might be something fundamental
I am not understanding. Unfortunately this severly impacted my ability to
create my animations. So I decided to solider on and apply (wrong) fixes over (wrong) fixes
in what I am calling the technique of _accumulation of wrong fixes:

- with a [first wrong fix] I was able to align canvas in generated video with the live preview
  provided by nanim (but it did not make sense)
- then I went on to implement the `crabDance` procedure below. It is likely that the base implementation
  contained bugs, but I fixed them all adding ad-hoc `fix` factors and hammering out my precioussss animations via trial-and-error!

What do the animations show?

- first animation uses the test input data, it has the crabs for part1 as red squares, and the crabs for part2
  as rusty squares. Part 2 is position symmetrically with respect to the vertical axis.
- second animation is the same but on real input and with a lot of hand picked fix factors.

but first here are the color-quantized crabs:

![a photo of Christmas Island red crabs with color quantization](crabs-quantized.png)

[languist]: https://github.com/github/linguist/blob/0afc7507fc995da3f9b73073cc64c719fcd79384/lib/linguist/languages.yml#L5330
[library]: https://github.com/okaneco/kmeans-colors
[amous red crabs]: https://en.wikipedia.org/wiki/Christmas_Island_red_crab
[Digital Color Meter]: https://support.apple.com/guide/digital-color-meter/welcome/mac
[PR pending]: https://github.com/EriKWDev/nanim/pull/17
[Opened Issue]: https://github.com/EriKWDev/nanim/issues/16
[first wrong fix]: https://github.com/EriKWDev/nanim/pull/17/commits/9650e0afd83a3f5303b755541bc1201b646c0e06
"""
nbCode:
  import nanim

  proc crabDance(startPos: seq[int], endPos: int, endPos2: int,
    scale=20.0, fixFactor=4.0, fixLagX=2, fixLagX2=0, fixLagY=1): Scene =
    let
      colors = colorsFromCoolors("https://coolors.co/202b38-009900-ffff66-dea584-b5453a")
      dark = colors[0]
      rust = colors[3]
      crab = colors[4]

    var scene = newScene() # a ref object, let would be also fine
    scene.setBackgroundColor(dark)
    # will need to handle a scale for puzzle input
    scene.width = int(max(startPos).float*scale) div 2
    scene.height = int(len(startPos).float*scale) div 2

    for i in 0 .. startPos.high:
      let square = newSquare(side=fixFactor*scale, centered=false)
      square.fill(crab)
      discard square.move(fixFactor*(startPos[i] - fixLagX).float*scale, fixFactor*(i + fixLagY).float*scale )
      scene.add(square)

      scene.onTrack i:
        scene.wait 500
        scene.play(square.move(fixFactor*(endPos - startPos[i]).float*scale, 0).with(duration=5000))
        scene.wait 500

      let square2 = newSquare(side=fixFactor*scale, centered=false)
      square2.fill(rust)
      discard square2.move(fixFactor*(max(startPos) - startPos[i] - fixLagX - fixLagX2).float*scale, fixFactor*(i + fixLagY).float*scale )
      scene.add(square2)

      scene.onTrack i + len(startPos):
        scene.wait 500
        scene.play(square2.move(fixFactor*(startPos[i] - endPos2).float*scale, 0).with(duration=5000))
        scene.wait 500

    return scene
  
  render(crabDance(testInput, testResult[1], testResult2[1]), "2021/test_dance.mp4")
nbVideo("2021/test_dance.mp4")

nbCode:
  render(crabDance(puzzleInput, puzzleResult[1], puzzleResult[1], scale=0.5, fixLagX=250, fixLagX2=1000), "2021/crab_dance.mp4")
nbVideo("2021/crab_dance.mp4")

nbText: """### highlights

- the median was the exact solution for part 1 and the mean almost the exact solution for part 2,
  see [this] (and references therein)
- a nice [easter egg] based on intcode
- a [comic like] visualization and [one that] looks like mine

[this]: https://www.reddit.com/r/adventofcode/comments/rawxad/2021_day_7_part_2_i_wrote_a_paper_on_todays/
[easter egg]: https://www.reddit.com/r/adventofcode/comments/rau12d/2021_day_7_easter_egg_in_inputs/
[comic like]: https://www.reddit.com/r/adventofcode/comments/rayjaa/2021_day_2_part_2_dart_crabs_together_strong/
[one that]: https://www.reddit.com/r/adventofcode/comments/raw9sg/2021_day_7_crabs_unite/
"""

nbSave
