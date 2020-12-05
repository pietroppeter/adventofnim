## AdventofNIMUtilities
# export all commonly used repos
# include prelude
# how do I write this (following does not work):
when false:
  template importExport(body: untyped) =
    import body
    export body

import os, strutils, times, parseutils, parseopt, hashes, tables, sets
export os, strutils, times, parseutils, parseopt, hashes, tables, sets
import sequtils, algorithm, strscans, strformat, bitops
export sequtils, algorithm, strscans, strformat, bitops

import macros

func emStar*(text: string): string = &"<em class=\"star\">{text}</em>"
const star* = emStar("*")
template gotTheStar* =
  nbText: &"""That's the right answer! You are {emStar("one gold star")} closer to saving your vacation."""

template nbOff*(body: untyped) = body

# make it colored
macro chk*(val, exp: untyped)  =
  let
    v = val.toStrLit
  quote do:
    when defined(chkOk):
      chkOk = (`val` == `exp`)
    else:
      var chkOk: bool = (`val` == `exp`)
    when not defined(myChkEchoOff):
      if chkOk:
        #styledWrite does not work I guess because stdin is broken!
        debugEcho "[OK] ", `v`, " = ", `val`
      else:
        debugEcho "[KO] ", `v`, " = ", `val`, "; expected = ", `exp`
