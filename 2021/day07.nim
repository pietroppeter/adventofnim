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

Colors:
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
nbSave

#[
  highlights:
    - median and mean see https://www.reddit.com/r/adventofcode/comments/rawxad/2021_day_7_part_2_i_wrote_a_paper_on_todays/
      and references by Michal there
    - viz fumettosa: https://www.reddit.com/r/adventofcode/comments/rayjaa/2021_day_2_part_2_dart_crabs_together_strong/
    - viz both parts dots: https://www.reddit.com/r/adventofcode/comments/raw9sg/2021_day_7_crabs_unite/

]#