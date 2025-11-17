require 'json'
require_relative 'helpers'



if File.exist?("../src/data/pokemon/level_up_learnsets.h")
  learnset_file = File.readlines("../src/data/pokemon/level_up_learnsets.h")
else
  learnset_file = []
  (1..9).each do |n|
    learnset_file += File.readlines("../src/data/pokemon/level_up_learnsets/gen_#{n}.h")
  end
end

tm_file = File.readlines("../src/data/pokemon/teachable_learnsets.h")


mons_by_id = JSON.parse(File.read("showdown_defaults/mons_by_id.json"))

em_mons = {}
em_tms = {}

current_pok = ""


learnset_file.each_with_index do |line, i|
	if line[0..5] == "static"
		current_pok = line.split("Move s")[1].split("Level")[0].downcase


    current_pok = species_sub(current_pok, true)
    em_mons[current_pok] = {}
    em_mons[current_pok]["learnset_info"] = {}
    em_mons[current_pok]["learnset_info"]["learnset"] = []
	end

  if line.include?("LEVEL_UP_MOVE") && !line.include?("#define")
    lvl_learned = line.split("(")[1].split(",")[0]
    move_name =   line.split("MOVE_")[1][0..-4].split("_").map {|m| m.downcase.capitalize }.join(" ")
    em_mons[current_pok]["learnset_info"]["learnset"] << [lvl_learned.to_i, showdown_subs(move_name)]
  end
end


tm_file.each_with_index do |line, i|
  if line[0..5] == "static"
    current_pok = line.split("u16 s")[1].split("Teachable")[0].downcase

    current_pok = species_sub(current_pok, true)


    # handle male forms
    begin
      em_mons[current_pok]["learnset_info"]["tms"] = []
    rescue
      current_pok = current_pok + "m"
      em_mons[current_pok]["learnset_info"]["tms"] = []
    end
  end

  if line.include?("MOVE_") && !line.downcase.include?("unavailable") && !line.match(/^\/\//)
    move_name = line.split("MOVE_")[1][0..-3].split("_").map {|m| m.downcase.capitalize }.join(" ")
    em_mons[current_pok]["learnset_info"]["tms"] << showdown_subs(move_name)
  end
end




growths = {}
growths["GROWTH_MEDIUM_FAST"] = 0
growths["GROWTH_ERRATIC"] = 1
growths["GROWTH_FLUCTUATING"] = 2
growths["GROWTH_MEDIUM_SLOW"] = 3
growths["GROWTH_FAST"] = 4
growths["GROWTH_SLOW"] = 5
possible_base_form = ""



type_defs = {}



var_definitions = {}


(1..10).each do |n|

  if n == 10
    poks = File.read("../src/data/pokemon/species_info.h").split("\n")
  else
    poks = File.read("../src/data/pokemon/species_info/gen_#{n}_families.h").split("\n")
  end


  poks.each_with_index do |line, i|

    # store any defined variable names
    if line.include?("#define")
      var_name = line.strip.split(" ")[1]
      definition = line.strip.split(" ")[2..-1].join(" ")
      var_definitions[var_name] = definition
    end

    if line.include?("[SPECIES_")
      possible_base_form = line.split("[SPECIES_")[1].split("]")[0].downcase.split("_")[0..-2].join("_").gsub("_", "")

      current_pok = species_sub(line.split("[SPECIES_")[1].split("]")[0]).downcase.gsub("_", "")
      em_mons[current_pok] ||= {}
      em_mons[current_pok]["bs"] = {}
      em_mons[current_pok]["evos"] = []
    end

    if line.include?("_SPECIES_INFO") && line.include?("#define")
      current_pok = species_sub(line.split("#define ")[1].split("_SPECIES_INFO")[0]).downcase.gsub("_", "")

      em_mons[current_pok] ||= {}
      em_mons[current_pok]["bs"] = {}
      em_mons[current_pok]["evos"] = []
    end

    if line.include?("_MISC_INFO") && line.include?("#define")
      current_pok = species_sub(line.split("#define ")[1].split("_MISC_INFO")[0]).downcase.gsub("_", "")
      em_mons[current_pok] ||= {}
      em_mons[current_pok]["bs"] = {}
      em_mons[current_pok]["evos"] = []
    end




    base_stats = [["baseHP", "hp"], ["baseAttack", "at"],["baseDefense", "df"],["baseSpeed", "sp"],["baseSpAttack", "sa"],["baseSpDefense", "sd"]] 
    base_stats.each do |stat|
      if line.include?(stat[0])

        binding.pry if current_pok == "Beartic"
        # always set value to first value of ternary
        if line.include?(" ? ")
          if match = line.match(/\.\w+\s*=\s*[^?]*\?\s*(\d+)/)

            em_mons[current_pok]["bs"][stat[1]] = match[1].to_i
          end
        else
          val = line[/\d+/].to_i
          em_mons[current_pok]["bs"][stat[1]] = val 
        end
      end
    end

    if line.include?("EVO_")
      begin
        em_mons[current_pok]["evos"] << parse_evolution(line)
      rescue
        binding.pry
      end
    end

    if line.include?(".abilities")
      

      begin
        abilities = line[/\{(.*?)\}/, 1].split(",").map(&:strip).map {|ab| format_name(ab, "ABILITY_")}
      rescue
        # Handle custom ability definitions
        line = sub_vars(var_definitions, line)
        abilities = line[/\{(.*?)\}/, 1].split(",").map(&:strip).map {|ab| format_name(ab, "ABILITY_")}
      end
      em_mons[current_pok]["abilities"] = abilities if !em_mons[current_pok]["abilities"]
    end

    if line.include?("#define") and line.include?("TYPE_")
      if line.include?(":")
        types = ["Fairy"]
      else
        var_name = line.split("#define")[1].split("{")[0].strip
        types = line[/\{(.*?)\}/, 1].split(",").map(&:strip).map {|ab| format_name(ab, "TYPE_")}.uniq
        type_defs[var_name] = types if !type_defs[var_name]
      end  
    end

    if line.include?(".types")
      type_value = line.split("=")[1].split(",")[0].strip
      
      line.gsub(/[A-Z]*_FAMILY_TYPE/, "TYPE_FAIRY")
      if type_defs[type_value]
        em_mons[current_pok]["types"] = type_defs[type_value]
      else
        types = line[/[\(\{}](.*?)[\)\}]/, 1].split(",").map(&:strip).map {|ab| format_name(ab, "TYPE_")}.uniq
        em_mons[current_pok]["types"] = types
      end
    end
    
    if line.include?(".growthRate")
      gr = growths[line.split(".growthRate = ")[1].split(",")[0]]

      if em_mons[current_pok]
        em_mons[current_pok]["gr"] = gr
      else
        em_mons[current_pok] = {}
        em_mons[current_pok]["gr"] = gr
      end

      if em_mons[possible_base_form]
        em_mons[possible_base_form]["gr"] = gr
      end
    end
  end
end

em_mons["unown"]["gr"] = 0
em_mons["basculin"]["gr"] = 0
em_mons["vivillon"]["gr"] = 0
em_mons["florges"]["gr"] = 0
em_mons["furfrou"]["gr"] = 0
em_mons["minior"]["gr"] = 3
em_mons["alcremie"]["gr"] = 0
em_mons["dudunsparce"]["gr"] = 0


# exception for aegislash and basculegion

# binding.pry
em_mons["aegislashshield"]["learnset_info"] = {}
em_mons["aegislashshield"]["learnset_info"]["learnset"] = em_mons["aegislash"]["learnset_info"]["learnset"]
em_mons["aegislashshield"]["learnset_info"]["tms"] = em_mons["aegislash"]["learnset_info"]["tms"]
em_mons["aegislashshield"]["gr"] = em_mons["aegislash"]["gr"]

em_mons["basculegionf"]["learnset_info"] = {}
em_mons["basculegionf"]["learnset_info"]["learnset"] = em_mons["basculegion"]["learnset_info"]["learnset"]
em_mons["basculegionf"]["learnset_info"]["tms"] = em_mons["basculegion"]["learnset_info"]["tms"]
em_mons["basculegionf"]["gr"] = em_mons["basculegion"]["gr"]




custom_megas = []
unhandled = []



em_mons = em_mons.transform_keys do |species_name|
  if mons_by_id[species_name]
    mons_by_id[species_name]["name"]
  else
    if showdown_ignore_list.index species_name
      species_name
    else
      # p species_name
      # male forms
      if species_name[-1] == "m" && mons_by_id[species_name[0..-2]]
        # p species_name[0..-2].capitalize
        species_name[0..-2].capitalize
      # custom mega forms
      elsif species_name[-4..-1] == "mega" && mons_by_id[species_name[0..-5]]
        # p species_name[0..-5].capitalize + "-Mega"
        custom_megas << species_name[0..-5].capitalize + "-Mega"
        species_name[0..-5].capitalize + "-Mega"
      elsif species_name[-5..-2] == "mega" && mons_by_id[species_name[0..-6]]
        # p species_name[0..-5].capitalize + "-Mega"
        custom_megas << species_name[0..-6].capitalize + "-Mega-" + species_name[-1].capitalize
        species_name[0..-6].capitalize + "-Mega-" + species_name[-1].capitalize
      else    
        unhandled << species_name
        species_name.capitalize
      end   
    end
  end
end

showdown_ignore_list.each do |species_name|
  em_mons.delete species_name
end

p "The following have been detected as custom megas #{custom_megas}"
p "The following have been detected as custom mons #{unhandled}"


File.write("./output/mons.json", JSON.pretty_generate(em_mons))

abils = {}
em_mons.each do |k,v|
  abils[k] = v["abilities"]
end

File.write("./output/abils.json", JSON.pretty_generate(abils))





