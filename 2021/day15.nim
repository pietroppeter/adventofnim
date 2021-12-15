import animu, nimib

nbInit(theme=useAdventOfNim)
nbText: """## Day 15: [Chiton](https://adventofcode.com/2021/day/15)

Today is about path search on a grid. I tend to struggle with these
since I never properly studied the theory.

### Part 1

We need to go from top left to bottom right minimizing sum of risk.
My strategy will be to create from given grid a new grid that
at every "node" (it usually pays to think of these problems in terms of graphs),
will tell me the direction I should come from in order to minimize the risk and
get there. The final path will be found by following directions from bottom right.

Here are the inputs:
"""
nbCode:
  let
    testInput = """
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581"""
    puzzleInput = readFile("2021/input15.txt")
nbText: """I will be using grid code from my Day09 (no blogpost published),
copying and pasting here the useful bits (I will need to think of an ergonomic
way to import from a notebook). I am also fine with having a sentinel value
for stuff outside the grid that is a high value.
"""
nbCode:
  type
    Coord = tuple[x, y: int]
    Grid[T] = object
      data: seq[T]
      yLen, xLen: int
      sentinel: T  # value for outside the grid
    GridInt = Grid[int]
    Dir = enum
      right, down, left, up

  func isOutside[T](c: Coord, g: Grid[T]): bool =
    c.x < 0 or c.x >= g.xLen or c.y < 0 or c.y >= g.yLen

  func toIndex[T](g: Grid[T], c: Coord): int =
    if c.isOutside(g):
      -1
    else:
      c.y*g.xLen + c.x

  func `[]`[T](g: Grid[T], c: Coord): T =
    let i = g.toIndex(c)
    if i < 0:
      g.sentinel
    else:
      g.data[i]

  # added today
  func `[]=`[T](g: var Grid[T], c: Coord, value: T) =
    let i = g.toIndex(c)
    if i >= 0:
      g.data[i] = value

  func parseInt(c: char): int =
    result = ord(c) - ord('0')
    assert result >= 0 and result <= 9

  func parse(text: string): GridInt =
    # result.data = newSeqOfCap(text.len)
    for line in text.strip.splitLines:
      result.data.add line.toSeq.map(parseInt)
      inc result.yLen
      if result.xLen == 0:
        result.xLen = line.len
      else:
        assert line.len == result.xLen
    result.sentinel = int.high

  iterator coords[T](g: Grid[T]): Coord =
    for y in 0 ..< g.yLen:
      for x in 0 ..< g.xLen:
        yield (x, y)

  func `+`(c: Coord, dir: Dir): Coord =
    case dir
    of right:
      (c.x + 1, c.y)
    of down:
      (c.x, c.y + 1)
    of left:
      (c.x - 1, c.y)
    of up:
      (c.x, c.y - 1)
nbText: """
Let's use it to parse inputs:
"""
nbCode:
  let
    testGrid = parse testInput
    puzzleGrid = parse puzzleInput
  dump (testGrid.xlen, testGrid.ylen)
  dump (puzzleGrid.xlen, puzzleGrid.ylen)
  dump testGrid.sentinel
nbText: """
I am not using a `GridDiff` (I did not copy related code),
I will be using a `GridRisk` which will tell
me minimal total risk up to here and best direction I should come from.

I will also use show functions to debug.
"""
nbCode:
  type
    Risk = tuple[risk: int, dir: Dir]
    GridRisk = Grid[Risk]

  func show(g: GridInt): string =
    for c in g.coords:
      result.add $g[c]
      if c.x == g.xLen - 1:
        result.add '\n'

  func show(g: GridRisk, paddingCount=4): string =
    for c in g.coords:
      if g[c].risk < g.sentinel.risk:
        result.add align($(g[c].risk), paddingCount)
      else:
        result.add align("*", paddingCount)
      if c.x == g.xLen - 1:
        result.add '\n'

  echo show testGrid
nbText: """
Here is the heart of the problem. Key for this is realizing
how to compute incrementally compute the risk.
"""
nbCode:
  func computeRisk(g: GridInt, gr: GridRisk, c: Coord): Risk =
    ## Computes Risk at Coord assuming Risk has been computed
    ## for cells on the left and above
    let
      riskUp = gr[c + up].risk + g[c]
      riskLeft = gr[c + left].risk + g[c]
    #debugEcho "computeRisk for c: ", c
    #debugEcho "  riskUp: ", riskUp
    #debugEcho "  riskLeft: ", riskLeft
    if riskUp <= riskLeft:
      (riskUp, up)
    else:
      (riskLeft, left)

  func computeGridRisk(g: GridInt): GridRisk =
    result.xLen = g.xLen
    result.yLen = g.ylen
    result.sentinel = (g.sentinel - 10, up) # forgot this line on first try
    # need to do - 10 to avoid overflow
    result.data = @[(0, up)]  # risk for initial position does not count
    for c in g.coords:
      if c == (0, 0): continue
      result.data.add g.computeRisk(result, c)

  func part1(gr: GridRisk): int =
    gr[(gr.xLen - 1, gr.yLen - 1)].risk
  
  let
    testGridRisk = computeGridRisk testGrid
    puzzleGridRisk = computeGridRisk puzzleGrid

  echo show testGridRisk

  dump part1 testGridRisk
  dump part1 puzzleGridRisk # 719 wrong, too high!
nbText: """
I am stuck at the moment with _a correct test result and an incorrect
puzzle result_. Not really sure how to debug.

... after looking at our discord aoc I got a useful hint (thanks @Michal58!),
the example only gives a path where the solution only goes down and to the right
and this was also my (wrong) assumption! It is indeed possible
for a minimal solution to wiggle around all directions but
my algorithm for sure is not going to find it.

So I really need to implement [Dijkstra](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
or [A*](https://en.wikipedia.org/wiki/A*_search_algorithm) algorithm!

But first let me give a minimal example that makes it clear why I need
the better approach:
"""
nbCode:
  let
    hintInput = "19999\n19111\n11191"
    hintGrid = parse hintInput
    hintGridRisk = computeGridRisk hintGrid
  
  echo show hintGrid, "\n", show hintGridRisk
nbText: """
... _(a few hours later) back to writing the blogpost and writing my solution_.

This morning I shared the hint on [advent of code subreddit](https://www.reddit.com/r/adventofcode/comments/rgszh7/2021_day_15_part_1_hint_if_you_get_correct_answer/)
and it has been quite popular! The irony is that I have not yet taken advantage of the hint and finalized my solution 😁, so let's get to it.

I will implement Dijkstra's algorithm because it is simpler than A* (although in general less powerful) and also because of its
[compelling history](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#History#:~:text=it%20was%20a%20twenty,pencil%20and%20paper)
(did you open last link on a chromium based browser? did you know what [text-fragments](https://web.dev/text-fragments/) are?
I didn't but having seen some weird highlighted stuff after google results I got curious...).

I will still be using my `GridRisk` type although it seems not completely appropriate...
The `risk` value will be the distance, I will try also to set the correct distance.

In the following implementation comments not in parenthesis are taken verbatim
from wikipedia's description of the algorithm. An important change I make
is to make sure I use a priority queue. Among the many Dijkstra implementations
that have been written today, I dare say this must rank among the worst...
""""
nbCode:
  import std / heapqueue  # (not among my standard aoc imports)

  type
    Node = tuple[coord: Coord, risk: int]

  proc `<`(a, b: Node): bool = a.risk < b.risk

  iterator neighbours[T](g: Grid[T], c: Coord): (Coord, Dir) =
    for dir in Dir:
      if not (c + dir).isOutside(g):
       yield (c + dir, dir)

  func dijkstra(g: GridInt): GridRisk =
    # (0. initialize result)
    result.xLen = g.xLen
    result.yLen = g.ylen
    result.sentinel = (g.sentinel, up)

    # 1. Mark all nodes unvisited. Create a set of all the unvisited nodes called the unvisited set.
    # (I will instead create a visited set)
    # (I will also create a priority queue for unvisited nodes, but I will start populating later)
    var
      visited = initHashSet[Coord]()
      unvisited = initHeapQueue[Node]()

    # 2. Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes.
    result.data = @[(0, up)]  # risk for initial position does not count
    for c in g.coords:
      if c == (0, 0): continue
      result.data.add @[result.sentinel]
    
    # 3. For the current node, consider all of its unvisited neighbors
    # and calculate their tentative distances through the current node.
    # Compare the newly calculated tentative distance to the current assigned value
    # and assign the smaller one
    var
      current = (0, 0)
      destination = (g.xLen - 1, g.yLen - 1)
      risk: int
    # 5. If the destination node has been marked visited then stop. The algorithm has finished.
    while destination not_in visited:
      for neighbour, dir in g.neighbours(current):
        if neighbour in visited:
          continue
        risk = result[current].risk + g[neighbour]
        if risk < result[neighbour].risk:
          result[neighbour] = (risk, dir)
          unvisited.push (neighbour, risk) # (push to queue)
      # 4. When we are done considering all of the unvisited neighbors of the current node,
      # mark the current node as visited and remove it from the unvisited set
      visited.incl current
      if current == destination: break # seems I need this (for puzzle input)

      # 6. Otherwise, select the unvisited node that is marked with the smallest tentative distance,
      # set it as the new current node, and go back to step 3.
      while current in visited: # (I think it may happen that I pull from queue stuff already visited)
        if len(unvisited) == 0:
          debugEcho "current: ", current
          raise ValueError.newException "whaaaat?"
        current = unvisited.pop().coord # (pull from queue)

  echo show dijkstra(hintGrid)
  echo "\n", show dijkstra(testGrid)
nbText: "results look good!"
nbCode:
  let puzzleGridDijkstra = dijkstra(puzzleGrid)
  echo puzzleGridDijkstra.data[^1]
gotTheStar
nbText: """
### Part 2

Now the map is bigger, and from what I hear around, the implementation
with the priority queue might be key to have a working solution now.

Let's create the bigger maps and solve part 2:
"""
nbCode:
  func biggerMap(g: GridInt): GridInt =
    result.xLen = g.xLen*5
    result.yLen = g.yLen*5
    result.sentinel = g.sentinel
    result.data = newSeqWith(len=g.data.len*25): 0
    for coord in result.coords:
      let
        smallCoord = (coord.x mod g.xLen, coord.y mod g.yLen)
        oneUps = (coord.x div g.xLen) + (coord.y div g.yLen)
      result[coord] = (g[smallCoord] + oneUps - 1) mod 9 + 1
  
  let
    testGridBigger = testGrid.biggerMap
    puzzleGridBigger = puzzleGrid.biggerMap
  echo show testGridBigger
nbText: "looks good, let's go for the prize:"
nbCode:
  let
    testGridBiggerDijkstra = testGridBigger.dijkstra
    puzzleGridBiggerDijkstra = puzzleGridBigger.dijkstra
  echo "part2(test): ", testGridBiggerDijkstra.data[^1]
  echo "part2(puzzle): ", puzzleGridBiggerDijkstra.data[^1]
gotTheStar
nbSave
