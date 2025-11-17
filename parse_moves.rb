require 'json'
require_relative 'helpers'


move_file = File.readlines("../src/data/moves_info.h")

current_move = ""
target = nil
is_drain = false
moves = {}

move_file.each_with_index do |line, i| 
	
	if line.include?(".name = COMPOUND_STRING")
		current_move = line.split('"')[1]
		moves[current_move] ||= {}
		moves[current_move]["flags"] ||= {}
		is_drain = false
		target = nil
	end

	if line.include?(".power")
		moves[current_move]["basePower"] = line[/\d+/].to_i
	end

	if line.include?(".type")
		moves[current_move]["type"] = line[/TYPE_([A-Z]+)/, 1].downcase.capitalize
	end

	if line.include?(".pp")
		if line.include?("UPDATED_MOVE_DATA")
			moves[current_move]["pp"] = line.scan(/\d+/)[1].to_i
		else
			moves[current_move]["pp"] = line[/\d+/].to_i
		end
	end

	if line.include?(".accuracy")
		moves[current_move]["acc"] = line[/\d+/].to_i
	end

	if line.include?(".priority")
		moves[current_move]["priority"] = line[/\d+/].to_i if line[/\d+/].to_i != 0
	end


	if line.include?(".target")
		if line.include?("BOTH")
			moves[current_move]["target"] = "allAdjacentFoes"
		end

		if line.include?("FOES_AND_ALLY") 
			moves[current_move]["target"] = "allAdjacent"
		end
	end

	if line.include?(".criticalHitStage")
		moves[current_move]["crit_stage"] = line[/\d+/].to_i
	end

	if line.include?(".strikeCount")
		hits = line[/\d+/].to_i
		moves[current_move]["multihit"] = [hits, hits]
	end

	if line.include?("EFFECT_MULTI_HIT")
		moves[current_move]["multihit"] = [2,5]
	end

	if line.include?(".recoil")
		moves[current_move]["recoil"] = [line[/\d+/].to_i, 100]
	end

	if line.include?(".additionalEffects")
		moves[current_move]["secondaries"] = true
	end

	if line.include?("EFFECT_ABSORB")
		is_drain = true
	end

	if line.include?("argument") and is_drain
		moves[current_move]["drain"] = [line[/\d+/].to_i, 100]
	end

	if line.include?(".alwaysCritical")
		moves[current_move][".willCrit"] = true
	end

	# FLAGS

	if line.include?("makesContact")
		moves[current_move]["makesContact"] = true
		moves[current_move]["flags"]["makesContact"] = true
	end

	if line.include?("punchingMove")
		moves[current_move]["isPunch"] = true
		moves[current_move]["flags"]["isPunch"] = true
	end

	if line.include?("bitingMove")
		moves[current_move]["isBite"] = true
		moves[current_move]["flags"]["isBite"] = true
	end

	if line.include?("ballisticMove")
		moves[current_move]["isBullet"] = true
		moves[current_move]["flags"]["isBullet"] = true
	end

	if line.include?("soundMove")
		moves[current_move]["isSound"] = true
		moves[current_move]["flags"]["isSound"] = true
	end

	if line.include?("pulseMove")
		moves[current_move]["isPulse"] = true
		moves[current_move]["flags"]["isPulse"] = true
	end

	if line.include?("kickingMove")
		moves[current_move]["isKick"] = true
		moves[current_move]["flags"]["isKick"] = true
	end

	if line.include?("slicingMove")
		moves[current_move]["isSword"] = true
		moves[current_move]["flags"]["isSword"] = true
	end

	if line.include?("boneMove")
		moves[current_move]["isBone"] = true
		moves[current_move]["flags"]["isBone"] = true
	end

	if line.include?("windMove")
		moves[current_move]["isWind"] = true
		moves[current_move]["flags"]["isWind"] = true
	end

	# custom move flags
	if line.match(/\..*Move = TRUE,/)
		flag_name =  "is" + line[/\.(\w+)Move/, 1].capitalize
		if !moves[current_move][flag_name] and !"Slicing,Punching,Kicking,Biting".include?(line[/\.(\w+)Move/, 1].capitalize)
			moves[current_move][flag_name] = true
			moves[current_move]["flags"][flag_name] = true
		end

	end
end



File.write("output/moves.json", JSON.pretty_generate(moves))
