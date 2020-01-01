import intcode, deques, strformat, sets

let p23 = "2019/day23.txt".readFile.parseProgram

const numComputers = 50

var p: array[numComputers, Program]

type
  Packet = tuple
    source, dest, x, y: int
  Network = tuple
    packetQueue: array[numComputers, Deque[Packet]]  # index is dest
    packetEmpty: array[numComputers, bool]

var
  stepOk: bool
  pack: Packet
  net: Network
  nat = (255, 255, 255, 255).Packet
  monitor: HashSet[int]

for i in 0 ..< numComputers:
  p[i] = p23
  p[i].inQ.push i
  net.packetQueue[i] = initDeque[Packet]()

var cycle = 0

const maxCycle = 1000_000
  
proc hasPacketFor(net: Network, i: int): bool =
  net.packetQueue[i].len > 0

proc pop(net: var Network, i: int): Packet =
  net.packetQueue[i].popFirst

proc push(net: var Network, pack: Packet) =
  net.packetQueue[pack.dest].addLast pack

proc isIdle(net: Network): bool =
  for i in 0 ..< numComputers:
    if not net.packetEmpty[i] or net.packetQueue[i].len > 0:
      return false
  return true

proc isValid(nat: Packet): bool =
  not (nat == (255, 255, 255, 255))

block computing:
  while cycle < maxCycle:
    # echo "cycle: ", cycle
    for i in 0 ..< numComputers:
      stepOk = (p[i].step == 1)
      # handle incoming packets
      if not stepOk:
        if net.hasPacketFor i:
          net.packetEmpty[i] = false
          pack = net.pop i
          # echo pack
          p[i].inQ.push pack.x
          p[i].inQ.push pack.y
        else:
          net.packetEmpty[i] = true
          # echo "no pack for ", i
          p[i].inQ.push -1
        stepOk = (p[i].step == 1)
        if not stepOk:
          raise ValueError.newException "error in program " & $i
      # handle outcoming packets
      if p[i].outQ.len >= 3:
        pack = (i, p[i].outQ.pop, p[i].outQ.pop, p[i].outQ.pop).Packet
        # echo pack
        if pack.dest == 255:
          echo fmt"on cycle {cycle}, nat receives packet {pack}"
          nat = pack
        else:
          net.push pack
    if net.isIdle and nat.isValid:
      pack = nat
      pack.dest = 0
      echo fmt"on cycle {cycle} network is idle, nat sends packet {pack}"
      net.push pack
      if pack.y in monitor:
        break computing
      monitor.incl pack.y
    inc cycle

echo "part 2: ", pack
