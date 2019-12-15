import strscans, strutils, sequtils, tables, strformat, sugar

var indent = 0

const
  debug = false

template myEcho(text: untyped) =
  if debug: echo " ".repeat(indent*2), text

type
  Material = tuple[quantity: int, name: string]
  Reaction = tuple[ingredients: seq[Material], target: Material]
  Recipes = Table[string, Reaction]  # for every material I will only have 1 recipe!
  Inventory = Table[string, int]

proc parseMaterial(text: string): Material =
  if scanf(text, "$i $w", result.quantity, result.name):
    return result
  else:
    raise ValueError.newException "cannot parse material: " & text

assert "10 ORE".parseMaterial == (10, "ORE")

proc parseReaction(text: string): Reaction =
  let splitText = text.split(" => ")
  assert splitText.len == 2
  result.ingredients = splitText[0].split(", ").map(parseMaterial)
  result.target = splitText[1].parseMaterial

assert "7 A, 1 B => 1 C".parseReaction == (@[(7, "A"), (1, "B")], (1, "C"))
assert "10 ORE => 10 A".parseReaction == (@[(10, "ORE")], (10, "A"))

proc `$`(material: Material): string = fmt"{material.quantity} {material.name}"

proc `$`(reaction: Reaction): string = reaction.ingredients.map(`$`).join(", ") & " => " & $reaction.target

assert "7 A, 1 B => 1 C" == $(@[(7, "A"), (1, "B")], (1, "C"))
assert "10 ORE => 10 A" == $(@[(10, "ORE")], (10, "A"))


proc parseRecipes(text: string): Recipes =
  var reaction: Reaction
  for line in text.splitLines:
    reaction = line.parseReaction
    result[reaction.target.name] = reaction

let
  recipes1 = """
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL""".parseRecipes

var inventory: Inventory

proc produce(recipes: Recipes, material: Material, inventory: var Inventory): int =
  ## return quantity of ORE necessary to produce material
  if material.name notin recipes:
    raise ValueError.newException "Cannot find a recipe for " & material.name
  if material.name in inventory and inventory[material.name] > 0:
    if inventory[material.name] >= material.quantity:
      return 0
    else:
      # remove temporarily from inventory, compute number od OREs to produce residual and put back full quantty
      let residual = material.quantity - inventory[material.name]
      myEcho fmt"found {inventory[material.name]} of {material.name} in inventory, I need to produce only {residual}"
      inventory.del material.name
      inc indent 
      result += recipes.produce((residual, material.name), inventory)
      dec indent 
      inventory[material.name] += material.quantity - residual
      myEcho fmt"now inventory has {inventory[material.name]} of {material.name}"
      return result
  let reaction = recipes[material.name]
  myEcho fmt"producing {reaction.target.quantity} of {material.name} using reaction: {reaction}"
  for ingredient in reaction.ingredients:
    if ingredient.name == "ORE":
      myEcho fmt"mining " & $ingredient
      result += ingredient.quantity
    else:
      inc indent
      result += recipes.produce(ingredient, inventory)
      dec indent
      myEcho "consuming " & $ingredient
      inventory[ingredient.name] -= ingredient.quantity
  myEcho fmt"done producing {reaction.target.quantity} of {material.name} using reaction: {reaction}"
  inventory[reaction.target.name] = reaction.target.quantity
  if material.quantity > reaction.target.quantity:
    myEcho "not enough produced by the reaction"
    inc indent
    result += recipes.produce(material, inventory)
    dec indent

myEcho "total ORE needed: " & $recipes1.produce((1, "FUEL"), inventory)
myEcho "inventory: " & $inventory
    
let recipes0 = "2019/day14.txt".readFile.parseRecipes

var minedOre: int

inventory.clear
minedOre = recipes0.produce((1, "FUEL"), inventory)
echo "total ORE needed: " & $minedOre
echo "inventory: " & $inventory

const totalOre = 1_000_000_000_000

var
  fuel = (totalOre div minedOre).int  # on my pc int is not int64???
  residualOre = (totalOre mod minedOre).int

echo "fuel: ", fuel
echo "residualOre: ", residualOre

for k, v in inventory.mpairs:
  v = minedOre.int*v

inventory.del "FUEL"
while residualOre > 0:
  let invCopy = inventory

  minedOre = recipes0.produce((1, "FUEL"), inventory)
  echo "minedOre: ", minedOre
  # echo inventory
  inc fuel
  inventory.del "FUEL"
  residualOre -= minedOre
  echo "residualOre: ", residualOre

  var invDelta: Inventory
  for k in invCopy.keys:
    if invCopy[k] != inventory[k]:
      invDelta[k] = invCopy[k] - inventory[k]

  var
    bestMultiplier = int.high
    mul: int
  for k, v in invDelta:
    if v <= 0:
      continue
    mul = inventory[k] div v
    if mul < bestMultiplier:
      bestMultiplier = mul
  dump bestMultiplier

  fuel += bestMultiplier
  if bestMultiplier == 598:
    echo inventory
  for k, v in invDelta:
    inventory[k] -= bestMultiplier*v
    if inventory[k] < 0:
      raise ValueError.newException "somehting went wrong"
  echo "fuel: ", fuel
  