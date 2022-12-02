import batteries

type
  Day* = object
    num*: int
    title*: string
    summary*: string

func mdTitle*(d: Day): string =
  fmt"## [Day {d.num}](https://adventofcode.com/2022/day/{d.num}): " & d.title


func filename*(d: Day): string =
  fmt"2022/day{d.num:02}.txt"

func emStar*(text: string): string = &"<em class=\"star\">{text}</em>"
const star* = emStar("*")
template gotTheStar* =
  nbText: &"""> That's the right answer! You are {emStar("one gold star")} closer to collecting enough star fruit."""

let mdRefs* = """
[nim]: https://github.com/nim-lang/nim
[nimib]: https://github.com/pietroppeter/nimib
[p5nim]: https://github.com/pietroppeter/p5nim
[batteries]: https://github.com/AngelEzquerra/nim-batteries
[nimble]: https://github.com/nim-lang/nimble
"""

