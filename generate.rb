require 'json'


p "generating pokemon data"
`ruby parse_mons.rb`

p "generating move data"
`ruby parse_moves.rb`

p "generating trainer sets"
`ruby parse_sets.rb`


mons = JSON.parse(File.read("./output/mons.json"))
moves = JSON.parse(File.read("./output/moves.json"))
sets = JSON.parse(File.read("./output/sets.json"))

npoint = {formatted_sets: sets, poks: mons, moves: moves}

File.write('./Dynamic-Calc/backups/test.js', 'backup_data = ')
File.write('./Dynamic-Calc/backups/test.js', JSON.pretty_generate(npoint), mode: 'a+')

p "calc can viewed by opening Dynamic-Calc/index.html in your browser"

