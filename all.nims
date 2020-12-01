exec "nim c -r 2020/day01"
exec "nim c readme"
"README.md".writeFile(staticExec("readme index.html"))