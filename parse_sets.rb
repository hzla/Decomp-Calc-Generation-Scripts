require_relative 'helpers'
require_relative 'nature_calc'
require 'json'


$mons = JSON.parse(File.read("./output/mons.json"))



def generate_sets 
	trainers = File.readlines("../src/data/trainers.party")
	trainers += ["","","","","","","","","","","",""] #padding
	mons = $mons
	

	formatted_sets = {}

	# 136 male singles
	# 120 female singles
	# 128 doubles

	tr_name = ""
	tr_class = ""
	raw_tr_name = ""
	sub_index = 0
	battle_type = ""
	battle_type_value = 0
	pok_names = []
	ai_tags = []
	status = nil

	inComment = false



	statuses = {"Frostbite" => "Frozen", "Burn" => "Burned", "Toxic Poison" => "Badly Poisoned"}
	trainer_pok_counts = {}


	trainers.each_with_index do |line, i|

		# skip one line commens
		if line.include?("/*") and line.include?("*/")
			next
		# skip comment start
		elsif line.include?("/*") and !line.include?("*/")
			inComment = true
		# skip comment end 
		elsif line.include?("*/")
			inComment = false
			next
		end
		next if inComment

		if line.include?("===")
			tr_name = line.split("TRAINER_")[1][0..-6]
			# p trainers[i + 1].split("Name: ")[1].strip.upcase
			begin
				raw_tr_name = trainers[i + 1].split("Name: ")[1].strip.upcase
			rescue
				raw_tr_name = ""
			end

			tr_class = trainers[i + 2].split("Class: ")[1].strip
			gender = trainers[i + 4].split("Gender: ")[1].strip
			sub_index = 0
			trainer_count = tr_name.split("_")[-1].strip
			pok_names = []

			ai_tags = []

			trainer_pok_counts = {}


			if trainers[i + 7] && trainers[i + 7].include?("AI: ")
				ai_tags = trainers[i + 7][4..-1].strip.split(" / ")
				ai_tags.delete("Smart Mon Choices")
			end

			battle_type = trainers[i + 6].include?("Yes") ? "Doubles" : "Singles"

			if battle_type == "Doubles"
				battle_type_value = 128
			else
				battle_type_value = gender == "Male" ? 136 : 120
			end

			
			if trainer_count.match?(/\A[-+]?\d+\z/) 
				
				trainer_count = trainer_count.to_i
				
				if trainer_count > 1
					tr_name = tr_name.split("_")[0..-2].map {|s| s.downcase.capitalize}.join(" ") + "#{trainer_count} "
				else
					tr_name = tr_name.split("_")[0..-2].join("_")
					tr_name = tr_name.split("_").map {|s| s.downcase.capitalize}.join(" ")
				end
			else
				tr_name = tr_name.split("_").map {|s| s.downcase.capitalize}.join(" ")
			end	

			if tr_name[-1].match?(/\A[-+]?\d+\z/) 
				tr_name += " "
			end
		end



		if line.include?("Level: ")
			delta = nil
			level = line[7..-1].strip.to_i
			gender = false

			status = nil

			# For each optional field specified after level,  offset += 1
			offset = 0



			if level >= 200
				delta = 200 - level
				level = "#{delta}"
			end
		
			# Ability specified
			if trainers[i - 1].include?("Ability: ")
				ability = trainers[i - 1].split("Ability: ")[-1].strip.gsub("Rks S", "RKS S").gsub("Of Ruin", "of Ruin")
				species_name = trainers[i - 2].strip
			# no ability specified
			else
				species_name = trainers[i - 1].strip
				ability = ""
			end


			if species_name.include?("@")
				item = species_name.split("@ ")[-1].strip.gsub("Heavy Duty", "Heavy-Duty").gsub("Nevermeltice", "Never-Melt Ice").gsub("Never Melt", "Never-Melt")
			end
			species_name = species_name.split(" @")[0]
			if species_name.include?("(M)")
				gender = "Male"
				species_name = species_name.gsub(" (M)", "")
			elsif species_name.include?("(F)")
				gender = "Female"
				species_name = species_name.gsub(" (F)", "")
			end

			if trainers[i + 1].include?(" Nature")
				nature = trainers[i + 1].split(" Nature")[0]
				offset += 1			
			else
				pok_names << species_name.upcase
				nature = calculate_nature(raw_tr_name, pok_names, battle_type_value)
			end

			###### CUSTOM STRING FORMATTING FOR SHOWDOWN GOES HERE

			species_name = species_name.gsub(" Therian", "Therian").gsub("Mr ", "Mr. ").gsub(" Disguised", "").gsub("o-O", "o-o").gsub("-Pa'U", "-Pa'u").gsub("fetchd", "fetch’d").gsub(/ F$/, "-F").gsub("Paldea ", "Paldea-").gsub(/ M$/, "")

			if species_name == "Aegislash"
				species_name = "Aegislash-Shield"
			end
			species_name = "Oricorio" if species_name == "Oricorio Baile"
			species_name = "Silvally" if species_name == "Silvally-Normal"

			####################################################

			trainer_pok_counts[species_name] ||= {}


			set_name = "Lvl #{level} #{tr_class} #{tr_name} "

			# to handle same level same species within same trainer
			dup_counter = 0
			until !trainer_pok_counts[species_name][set_name]	
				dup_counter += 1
				set_name = "Lvl #{level}#{"*" * dup_counter} #{tr_class} #{tr_name} "
			end

			trainer_pok_counts[species_name][set_name] = true
			dup_counter = 0
				
			if trainers[i + 1 + offset].include?("IVs:")
				ivs = parse_stats trainers[i + 1 + offset], 31
				offset += 1
			else
				ivs = {"hp": 31, "at": 31, "df": 31, "sa": 31, "sd": 31, "sp": 31,}
			end

			if trainers[i + 1 + offset].include?("EVs")
				evs = parse_stats trainers[i + 2 + offset], 0
				offset += 1
			else
				evs = {}
			end
			moves = []


			if trainers[i + 1 + offset].include?("- ")		
				
				# binding.pry if set_name.include?("Roark")
				[1,2,3,4].each do |n|
					if trainers[i + n + offset].include?("- ")
						move = trainers[i + n + offset].split("- ")[1].strip
						moves << showdown_subs(move)
					end
				end
			else
				begin
					moves = get_moves_at_level(mons[species_name]["learnset_info"]["learnset"], level)
				rescue
					moves = []
					p "could not find learnset into for #{species_name}"
				end
			end

			formatted_sets[species_name] ||= {}
			set_name = set_name.gsub(/  $/, " ")

			formatted_sets[species_name][set_name] = {
				"ivs": ivs,
				"evs": evs,
				"item": item,
				"level": level,
				"nature": nature,
				"battle_type": battle_type,
				"moves": moves,
				"sub_index": sub_index,
				"ai_tags": ai_tags 
			}

			mega_species_name = nil
			transformed_species_name = nil

			if delta
				formatted_sets[species_name][set_name]["sublevel"] = delta
			end

			if gender
				formatted_sets[species_name][set_name]["gender"] = gender
			end

			# Check if a mega item was applied to a non mega 
			if item && item[-3..-1] == "ite" && item != "Eviolite" && !species_name.include?("-Mega")
				mega_species_name = species_name + "-Mega"
			elsif item && item[-5..-2] == "ite " && !species_name.include?("-Mega")
				mega_species_name = species_name + "-Mega-#{item[-1]}"
			end

			if mega_species_name
				formatted_sets[mega_species_name] ||= {}

				p mega_species_name

				formatted_sets[mega_species_name][set_name] = formatted_sets[species_name][set_name].clone
				# p formatted_sets[species_name][set_name]
				formatted_sets[mega_species_name][set_name][:sub_index] = 6
				# p formatted_sets[species_name][set_name][:sub_index]
				ability_index = mons[species_name]["abilities"].index(ability)

				begin
					formatted_sets[mega_species_name][set_name]["ability"] = mons[mega_species_name]["abilities"][ability_index]
				rescue
					formatted_sets[mega_species_name][set_name]["ability"] = mons[mega_species_name]["abilities"][0]
					p "can't find mega ability for #{mega_species_name} with base ability #{ability}, setting to #{mons[mega_species_name]["abilities"][0]}"
				end

				if !formatted_sets[mega_species_name][set_name]["ability"]
					formatted_sets[mega_species_name][set_name]["ability"] = mons[mega_species_name]["abilities"][0]
				end
			end
			sub_index += 1	
		end
	end
	File.write("./output/sets.json", JSON.pretty_generate(formatted_sets))
end

def add_species_transformations formatted_sets
	new_formatted_sets = formatted_sets.clone

	new_formatted_sets.each do |species, set_names|
		new_formatted_sets[species].each do |set_name, set_data|
			if transform_items[species]
				if set_data["item"] == transform_items[species][0] || (species == "Rayquaza" and set_data["moves"].include?("Dragon Ascent"))
					formatted_sets[transform_items[species][1]] ||= {}
					formatted_sets[transform_items[species][1]][set_name] = set_data.clone

					formatted_sets[transform_items[species][1]][set_name][:sub_index] = 6
					p "#{species}"
					formatted_sets[transform_items[species][1]][set_name]["ability"] = $mons[transform_items[species][1]]["abilities"][0]

					p "#{species} changed to #{transform_items[species][1]} on #{set_name} with ability #{$mons[transform_items[species][1]]["abilities"][0]}"
				end
			end
		end
	end
	File.write("./output/sets.json", JSON.pretty_generate(formatted_sets))
end

generate_sets
add_species_transformations(JSON.parse(File.read("./output/sets.json")))



