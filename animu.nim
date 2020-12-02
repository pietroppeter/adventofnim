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
import sequtils, algorithm, strscans
export sequtils, algorithm, strscans

template gotTheStar* = nbText: "The solution is correct! <em class=\"star\">*</em>"

