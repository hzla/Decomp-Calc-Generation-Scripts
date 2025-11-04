require 'json'

def generate title
	p "generating pokemon data"
	`ruby parse_mons.rb`

	p "generating move data"
	`ruby parse_moves.rb`

	p "generating trainer sets"
	`python3 parse_trainers.py ../src/data/trainers.h ../src/data/trainer_parties.h ./output/trainers.txt`
	`ruby parse_sets.rb`


	mons = JSON.parse(File.read("./output/mons.json"))
	moves = JSON.parse(File.read("./output/moves.json"))
	sets = JSON.parse(File.read("./output/sets.json"))

	npoint = {title: title, poks: mons, formatted_sets: sets, moves: moves}

	File.write("./output/npoint.json", npoint.to_json)


	p "npoint data source outputted to pokeemerald-expansion/calc/output/npoint.json"

end

generate ARGV[0]