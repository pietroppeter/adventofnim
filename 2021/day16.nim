import animu, nimib

nbInit(theme=useAdventOfNim)
nbText: """## Day 16: [Packet Decoder](https://adventofcode.com/2021/day/16)

Today is about parsing a binary signal here is the first example
signal to practice one of the basic function I will be using (`toBin`)
"""
nbCode:
  echo 0xD2FE28.toBin(len=24)
  echo "VVVTTTAAAAABBBBBCCCCC"
nbText: """
At first I thougth I could try
with [binaryparse](https://github.com/PMunch/binaryparse):
"""

nbCode:
  import binaryparse, streams

  block:
    let test1 = newStringStream("\xD2\xFE\x28")

    createParser(packet):
      u3: version
      u3: typeId
    
    var data = packet.get(test1)
    dump data
nbText: """
But the result is odd ([bug?](https://github.com/PMunch/binaryparse/issues/18)). So then I could try with
[binarylang](https://github.com/sealmove/binarylang) and the first step went better:
"""
nbCode:
  import binarylang

  block:
    let test1 = newStringBitStream("\xD2\xFE\x28")

    struct(packet):
      u3: version
      u3: typeId

    var data = packet.get(test1)
    # data is an object without a $ proc defined
    echo data.version
    echo data.typeId
nbText: """But after this I was lost. I think it can be done with this library
and it would be rather cool but what I could gather in limited time
from documentation and code was not enough.

So I decided to start from scratch. And let's start with parsing the input.
It would be much nicer to use sequence of bytes and keep information compact,
but it is much easier to pack a `char` for each bit (!). I will also
be using our standard int for whatever small int comes my way...
"""
nbCode:
  func parseHex(c: char): int =
    if c in '0' .. '9':
      ord(c) - ord ('0')
    elif c in 'A' .. 'F':
      10 + ord(c) - ord ('A')
    else:
      0  # should raise error

  # parse string to string and waste a lot of info...
  func parse(text: string): string =
    for c in text:
      result.add c.parseHex.toBin(len=4)

  echo 'A'.parseHex
  echo parse "D2FE28"
  echo "VVVTTTAAAAABBBBBCCCCC"
nbText: """
and then, slowly but surely I went on building my implementation bit by bit,
adding debugging stuff and being as usual a bit too verbose.
Packet type contains way too much info... but in the end I manage to dots all my _i_s...

It is all spread here without a lot of commentary and possibly with too many outputs.
"""
nbCode:
  type
    PacketKind = enum
      pkLiteral, pkOperator
    Packet = ref object
      version: int
      typeId: int
      case kind: PacketKind
      of pkLiteral:
        value: int
      of pkOperator:
        lengthTypeId: char
        totBits: int
        numPackets: int
        packets: seq[Packet]

  func `$`(p: Packet): string =
    result = &"Packet(version: {p.version}, typeId: {p.typeId}, kind: {p.kind}"
    case p.kind
    of pkLiteral:
      result &= &", value: {p.value})"
    of pkOperator:
      result &= &", lengthTypeId: {p.lengthTypeId}, totBits: {p.totBits}, numPackets: {p.numPackets}):\n"
      for packet in p.packets:
        result &= indent($packet, 2) & '\n'

  var
    packet: Packet
    bits: string

  func parseLiteral(bits: string, i: var int): int =
    var
      valueBits: string
      next = true
    while next:
      if bits[i] == '0':
        next = false
      inc i
      valueBits &= bits[i ..< i + 4]
      inc i, 4
    discard valueBits.parseBin(result)

  template check =
    # not sure if in the end this is actually an error
    if i >= bits.len:
      #debugEcho "ERR"
      #debugEcho "i: ", i
      #debugEcho "bits.len: ", bits.len
      #debugEcho "packet: ", packet
      return i

  proc parsePacket(bits: string, packet: var Packet, start: int): int =
    var i = start
    packet = Packet()
    check
    i += bits.parseBin(packet.version, start=i, maxLen=3)
    check
    i += bits.parseBin(packet.typeId, start=i, maxLen=3)
    check
    if packet.typeId == 4:
      packet = Packet(version: packet.version, typeId: packet.typeId, kind: pkLiteral)
      packet.value = bits.parseLiteral(i)
      check
      return i
    packet = Packet(version: packet.version, typeId: packet.typeId, kind: pkOperator)
    packet.lengthTypeId = bits[i]
    inc i
    check
    var maxBits: int
    if packet.lengthTypeId == '0':
      i += bits.parseBin(packet.totBits, start=i, maxLen=15)
      check
      maxBits = i + packet.totBits
      packet.numPackets = 100
    else:
      i += bits.parseBin(packet.numPackets, start=i, maxLen=11)
      check
      maxBits = int.high
    # debugEcho "i: ", i, "; maxBits: ", maxBits, "; numPackets: ", packet.numPackets
    while i < maxBits and packet.packets.len < packet.numPackets:
      var newPacket = Packet()
      i = bits.parsePacket(newPacket, i)
      #debugEcho "i: ", i
      packet.packets.add newPacket
      check
    return i

  func sumVersions(packet: Packet): int =
    result += packet.version
    if packet.kind == pkOperator:
      for p in packet.packets:
        result += sumVersions p

  func pvalue(packet: Packet): int = # I already have value for literal
    case packet.typeId
    of 0:
      sum(packet.packets.mapIt(it.pvalue))
    of 1:
      prod(packet.packets.mapIt(it.pvalue))
    of 2:
      min(packet.packets.mapIt(it.pvalue))
    of 3:
      max(packet.packets.mapIt(it.pvalue))
    of 4:
      packet.value
    of 5:
      assert packet.packets.len == 2
      if packet.packets[0].pvalue > packet.packets[1].pvalue:
        1
      else:
        0
    of 6:
      assert packet.packets.len == 2
      if packet.packets[0].pvalue < packet.packets[1].pvalue:
        1
      else:
        0
    of 7:
      assert packet.packets.len == 2
      if packet.packets[0].pvalue == packet.packets[1].pvalue:
        1
      else:
        0
    else:
      0

  template example(text: string) =
    echo "example: ", text
    bits = parse text
    discard parsePacket(bits, packet, 0)
    echo packet
    echo "sumVersions: ", packet.sumVersions
    echo "pvalue: ", packet.pvalue

  example "D2FE28"

nbCode: example "38006F45291200"
nbCode: example "EE00D40C823060"
nbText: """
> Here are a few more examples of hexadecimal-encoded transmissions:
> 
> - `8A004A801A8002F478` represents an operator packet (version 4) which contains an operator packet (version 1) which contains an operator packet (version 5) which contains a literal value (version 6); this packet has a version sum of 16.
> - `620080001611562C8802118E34` represents an operator packet (version 3) which contains two sub-packets; each sub-packet is an operator packet that contains two literal values. This packet has a version sum of 12.
> - `C0015000016115A2E0802F182340` has the same structure as the previous example, but the outermost packet uses a different length type ID. This packet has a version sum of 23.
> - `A0016C880162017C3686B18A3D4780` is an operator packet that contains an operator packet that contains an operator packet that contains five literal values; it has a version sum of 31.
"""
nbCode: example "8A004A801A8002F478"
nbCode: example "620080001611562C8802118E34"
nbCode: example "C0015000016115A2E0802F182340"
nbCode: example "A0016C880162017C3686B18A3D4780"
nbCode: example readFile("2021/input16.txt")
nbText: """
> For example:
>
> - `C200B40A82` finds the sum of 1 and 2, resulting in the value 3.
> - `04005AC33890` finds the product of 6 and 9, resulting in the value 54.
> - `880086C3E88112` finds the minimum of 7, 8, and 9, resulting in the value 7.
> - `CE00C43D881120` finds the maximum of 7, 8, and 9, resulting in the value 9.
> - `D8005AC2A8F0` produces 1, because 5 is less than 15.
> - `F600BC2D8F` produces 0, because 5 is not greater than 15.
> - `9C005AC2F8F0` produces 0, because 5 is not equal to 15.
> - `9C0141080250320F1802104A08` produces 1, because 1 + 3 = 2 * 2.
"""
nbCode: example "C200B40A82"
nbCode: example "04005AC33890"
nbCode: example "880086C3E88112"
nbCode: example "CE00C43D881120"
nbCode: example "D8005AC2A8F0"
nbCode: example "F600BC2D8F"
nbCode: example "9C005AC2F8F0"
nbCode: example "9C0141080250320F1802104A08"
gotTheStar
gotTheStar
nbSave