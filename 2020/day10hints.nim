import nimib, nimoji, markdown
nbInit

var hint = 1
template nbxHint(details: string) =
  nbText: "<details><summary>Hint " & $hint & "</summary><p>" & details.emojize.markdown & "</p></details>"
  inc hint

nbText: """# 2020, Day 10, Part 2 - Hints

My background being in mathematics, I do suffer a bit parse-heavy days, while I enjoy thoroughly days like today.
Below a sequence of micro-hints to help those who have the reciprocal suffering.
Following them all the way should result in something similar to my implementation,
but you might want to stop earlier and come up with your own version.

## Problem
You have to implement a function `solve2` that counts all possible arrangements of a sequence of integers according to the constraints:
* start with 0
* any subsequent element should have a difference with the previous that is either 1, 2 or 3
* end with max element of the sequence + 3

## (Advent of) Hints

I am not really using [nim](https://nim-lang.org/) notation in the hints and they should be agnostic with respect to the programming language.
"""
nbxHint: "Sort your input if you haven't already (you should have in part1) and realize there are no duplicates"
nbxHint: "Is there a way to split the problem from a big sequence into several subsequences?" 
nbxHint: "In particular, are there elements in the sequence that **cannot** be skipped in any configuration (e.g. every configuration must contain them)?"
nbxHint: "I mean in the sequences `[0 3 4]` or `[0 1 4]` (or `[0 2 5]` or `[0 3 5]`) can I ever skip the middle element? How many configurations do those have?"
nbxHint: "yep, those sequences only have one conifguration possible"
nbxHint: "realize that you can in fact split your problem whenever you have an element that has a difference of `3` with either the preceding or subsequent element"
nbxHint: "in particular realize that the absolute values of the elements do not really matter, only their differences :exploding_head:!"
nbxHint: "implement a `diff` function (output of the above sequences would be `(3 1)`, `(1 3)`, `(2 3)`, `(3 2)`; note that I changed the syle of parentheses: `[]` for original sequence and `()` for its differences."
nbxHint: "the new function we need to implement we call it `numArr` and computs number of possible arrangements given the differences of a (sub)sequence (it assumes first and last elements **must** be in the sequence)"
nbxHint: "previous hints imply that `numArr (s 3 t) = numArr(s)*numArr(t)` where `s` and `t` are subsequence :astonished:"
nbxHint: "now you are starting to realize that you will use recursion :turtle::turtle::turtle:"
nbxHint: "manually compute the result over all possible difference sequences of length 2 and 3 (without a `3` difference)"
nbxHint: "is there another difference configuration that will result in stuff you cannot skip, can you see it?"
nbxHint: "`numArr (s 2 2 t) = ?`"
nbxHint: "`numArr (s 2 2 t) = numArr(s)*numArr(t)`"
nbxHint: "you are almost there but not yet: now you can split problem from a big sequence into a subsequence for some special cases, how do I reduce the computation for a sequence that has none of this special cases? I need to be able to reduce the length of the sequence!"
nbxHint: "to count the number of arrangements start counting those which contain the second element (remember the first must be included) and then count those who do not"
nbxHint: "try with this sequence `(1 1 1 1)`, you can think of it as `[0 1 2 3 4]`"
nbxHint: "`numArr (x y s) = ?` where `x`, `y` are single differences and `s` is a subsequence"
nbxHint: "correct! `numArr (x y s) = numArr (y s) + numArr (x+y s)` :muscle:"
nbxHint: "(note that having excluded the special cases when one of the difference is `3` or two subsequent `2`s, now `x + y <= 3`)"
nbxHint: "that's about it, you can implement a recursion using this, trying to take care first of the special cases (short lengths, diff sequences containg `3` or two `2`s)"
nbxHint: "(optional) ok, you want more? what does speed up recursion in case you need to recompute previously computed results?"
nbxHint: "that's right: [memoization](https://en.wikipedia.org/wiki/Memoization)!"
nbxHint: "I am out of hints and you can just go and see my [implementation](https://github.com/pietroppeter/adventofnim/blob/master/2020/day10.nim)! Hope you enjoyed!"
nbSave