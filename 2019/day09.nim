import intcode

var p = "2019/day09.txt".readFile.parseProgram

p.inQ.push 1
echo "n steps: ", p.run
echo p.outQ.pop

p = "2019/day09.txt".readFile.parseProgram

p.inQ.push 2
echo "n steps: ", p.run
echo p.outQ.pop
