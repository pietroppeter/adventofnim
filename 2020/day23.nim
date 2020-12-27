import lists
import animu
ddebug

func initGame(s: seq[int], part2=false): (DoublyLinkedNode[int], DoublyLinkedRing[int]) =
  result[0] = newDoublyLinkedNode[int](s[0])
  result[1].append result[0]
  for i in 1..s.high:
    result[1].append s[i]
  if part2:
    for n in 10..1_000_000:
      result[1].append n

var (current, cups) = initGame(@[3,8,9,1,2,5,4,6,7])

func minusOne(value: int, size: int): int =
  result = value - 1
  if result == 0:
    result = size

proc nextValue(curValue: int, pickedUpValues: array[3, int], size: int): int =
  result = curValue.minusOne(size)
  while result in pickedUpValues:
    result = result.minusOne(size)

func pickUpValues(curNode: DoublyLinkedNode[int]): array[3, int] =
  result[0] = curNode.next.value
  result[1] = curNode.next.next.value
  result[2] = curNode.next.next.next.value

proc initDestSeq(cups: DoublyLinkedRing[int], size=9): seq[DoublyLinkedNode[int]] =
  result = newSeq[DoublyLinkedNode[int]](len=size)
  for c in cups.nodes:
    result[c.value - 1] = c

var dests = initDestSeq(cups)

proc move(current: var DoublyLinkedNode[int], dests: seq[DoublyLinkedNode[int]], size=9) =
  let
    pickedUpValues = current.pickUpValues
    nextValue = current.value.nextValue(pickedUpValues, size)
  ddump current.value
  ddump pickedUpValues
  ddump nextValue
  var
    firstRef = current.next
    lastRef = firstRef.next.next
  # remove 3 picked up values
  current.next = lastRef.next
  current.next.prev = current
  # find destination cup
  var destination = dests[nextValue - 1]
  # put back the cups
  destination.next.prev = lastRef
  lastRef.next = destination.next
  destination.next = firstRef
  firstRef.prev = destination
  # and change current
  current = current.next

proc check(cups: DoublyLinkedRing[int]) =
  decho "check"
  dind
  for node in cups.nodes:
    ddump node.value
    ddump node.next == nil
    ddump node.prev == nil
  dded

decho cups
#check cups
for i in 1..10:
  decho "move = ", i
  dind
  move current, dests
  dded
  #check cups
  decho cups

func answer(cups: DoublyLinkedRing[int]): string =
  var c = cups.find(1).next
  while c.value != 1:
    result.add $(c.value)
    c = c.next

echo "example(10): ", answer(cups)
for i in 11..100:
  move current, dests
echo "example(100): ", answer(cups)

(current, cups) = initGame(@[4,1,8,9,7,6,2,3,5]) #my input
dests = initDestSeq(cups)
for i in 1..100:
  move current, dests
echo "input(100): ", answer(cups) # 96342875

# part2
echo "part2, example"
(current, cups) = initGame(@[3,8,9,1,2,5,4,6,7], part2=true) # example
dests = initDestSeq(cups, size=1_000_000)
echo "initialized"
func answer2(cups: DoublyLinkedRing[int]): int =
  let c = cups.find(1).next
  debugEcho c.value
  debugEcho c.next.value
  c.value*c.next.value
for i in 1..10_000_000:
  if i mod 100_000 == 0:
    echo i div 100_000
  move current, dests, 1_000_000
echo cups.answer2

echo "part2, input"
(current, cups) = initGame(@[4,1,8,9,7,6,2,3,5], part2=true) # example
dests = initDestSeq(cups, size=1_000_000)
echo "initialized"
for i in 1..10_000_000:
  if i mod 100_000 == 0:
    echo i div 100_000
  move current, dests, 1_000_000
echo "part2 answer: ", cups.answer2
