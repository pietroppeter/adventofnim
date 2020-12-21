import strutils, parseutils, sets, tables, algorithm, sequtils

let example = """mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)"""

type
  FoodLabel = object
    ingredients: seq[string]
    allergens: seq[string]

proc parse(text: string): seq[FoodLabel] =
  var ingredients, allergens: string
  for line in text.splitLines:
    let i = parseUntil(line, ingredients, " (contains ")
    if i > 0:
      if parseUntil(line, allergens, ")", start = i + " (contains ".len) == 0:
        echo "ERROR cannot find closeParens in line ", line
      result.add FoodLabel(ingredients: ingredients.split(" "), allergens: allergens.split(", "))
    else:
      result.add FoodLabel(ingredients: line.split(" "), allergens: @[])

echo parse example

proc solve(s: seq[FoodLabel]): (int, string) =
  var
    ingredients = initHashSet[string]()
    thisIngredients = initHashSet[string]()
    allergens = initHashSet[string]()
    canContain = initTable[string, HashSet[string]]()
    canContain2 = initHashSet[string]()
  for f in s:
    thisIngredients = initHashSet[string]()
    for i in f.ingredients:
      thisIngredients.incl i
    ingredients.incl thisIngredients
    for a in f.allergens:
      allergens.incl a
      if a in canContain:
        canContain[a] = canContain[a].intersection thisIngredients
      else:
        canContain[a] = thisIngredients
  for a, i in canContain:
    canContain2 = canContain2.union i
    echo "a: ", a, "; i: ", i
  for f in s:
    for i in f.ingredients:
      if i notin canContain2:
        inc result[0]
  #result[1] = sorted(toSeq(canContain2)).join(",") # not correct!

echo solve(parse example)

let input = "2020/input21.txt".readFile
echo solve(parse input)
# done manually looking at the list (faster than implementing something)

# dairy: rcqb
# eggs: cltx
# fish: nrl
# nuts: qjvvcvz
# peanuts: tsqpn
# sesame: xhnk
# shellfish: tfqsb
# wheat: zqzmzl
# rcqb,cltx,nrl,qjvvcvz,tsqpn,xhnk,tfqsb,zqzmzl
