func transform(loopSize: int, subjectNumber = 7): int =
  result = 1
  for i in 1 .. loopSize:
    result = result*subjectNumber mod 20201227

assert transform(8) == 5764801
assert transform(11) == 17807724
assert transform(8, 17807724) == 14897079
assert transform(11, 5764801) == 14897079

const maxLoopSize = 20_201_227

func findLoopSize(publicKey: int): int =
  var value = 1
  for loopSize in 1 .. maxLoopSize:
    value = value*7 mod 20201227
    if value == publicKey:
      return loopSize
  debugEcho "ERROR maxLoopSize too small!"

assert findLoopSize(5764801) == 8
assert findLoopSize(17807724) == 11

let
  # based on my input
  cardPublicKey = 17773298
  doorPublicKey = 15530095
  cardLoopSize = findLoopSize(cardPublicKey)
  doorLoopSize = findLoopSize(doorPublicKey)

let
  encryptionKey = transform(cardLoopSize, doorPublicKey)
assert encryptionKey == transform(doorLoopSize, cardPublicKey)

echo "part 1: ", encryptionKey