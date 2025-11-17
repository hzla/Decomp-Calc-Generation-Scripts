def format_move_name(move_string)
  move_string
    .sub('MOVE_', '')
    .split('_')
    .map(&:capitalize)
    .join(' ')
end

def format_learnset_move_name(move_string)
	move_string
    .split(' ')
    .map(&:capitalize)
    .join(' ')
end

def parse_stats(str, default=31)
  # Default all IVs to 31
  ivs = {
    "HP"  => default,
    "Atk" => default,
    "Def" => default,
    "SpA" => default,
    "SpD" => default,
    "Spe" => default
  }

  return convert_keys(ivs) unless str

  s = str.sub(/^IVs:\s*/, "")

  s.split("/").each do |segment|
    segment.strip!
    next if segment.empty?

    if segment =~ /(\d+)\s*(HP|Atk|Def|SpA|SpD|Spe)/
      value = $1.to_i
      stat  = $2
      ivs[stat] = value
    end
  end

  convert_keys(ivs)
end

def convert_keys(old)
  {
    "hp" => old["HP"],
    "at" => old["Atk"],
    "df" => old["Def"],
    "sa" => old["SpA"],
    "sd" => old["SpD"],
    "sp" => old["Spe"]
  }
end

# non mega stones
def transform_items
	{
		"Dialga" => ["Adamant Orb", "Dialga-Primal"],
		"Palkia" => ["Lustrous Orb", "Palkia-Primal"],
		"Groudon" => ["Red Orb", "Groudon-Primal"],
		"Kyogre" => ["Blue Orb", "Kyogre-Primal"],
		"Zamazenta" => ["Rusted Shield", "Zamazenta-Crowned"],
		"Zacian" => ["Rusted Shield", "Zacian-Crowned"],
		"Rayquaza" => [nil, "Rayquaza-Mega"]
	}
end


def parse_evolution(str)
  if match = str.match(/\{([^}]*)\}/)
    args = match[1].split(/\s*,\s*/)

    method    = args[0].sub(/^EVO_/, "")
    parameter = args[1].sub(/^[^_]+_/, "")
    target    = args[2].sub(/^SPECIES_/, "")

    { method: method, parameter: parameter, target: target }
  else
    {}
  end
end

def format_name(move_string, prefix)
  formatted = move_string
    .sub(prefix, '')
    .split('_')
    .map(&:capitalize)
    .join(' ')

   showdown_subs(formatted)
end

def get_moves_at_level(learnset, level)
  learnset
    .select { |entry| entry[0] <= level }
    .sort_by { |entry| entry[0] }
    .last(4)
    .map { |entry| showdown_subs(format_learnset_move_name(entry[1])) }
end

def sub_vars var_definitions, line
	var_definitions.each do |k,v|
		line = line.gsub(k,v)
	end
	line
end


def species_sub species, snake_case=false
	subs = {
	    "_CAP" => "",
	    "_CLOAK" => "",
	    "_PLANT_CLOAK" => "",
	    "_PLANT" => "",
	    "_COMBAT_BREED" => "_Combat",
	    "_CROWED_SHIELD" => "_Crowned",
	    "_CROWED_SWORD" => "_Crowned",
	    "_DRIVE" => "",
	    "_EAST_SEA" => "_East",
	    "_WEST" => "",
	    "_FAMILY_OF_FOUR" => "_Four",
	    "_FEMALE" => "_F",
	    "_FLOWER" => "",
	    "_ICE_RIDER" => "_Ice",
	    "_NOICE_FACE" => "_Noice",
	    "_ORIGINAL_COLOR" => "_Original",
	    "_PLUMAGE" => "",
	    "_POKE_BALL" => "_Pokeball",
	    "_ZEN_MODE" => "_Zen",
	    "_TWO" => "",
	    "_HERO" => "",
	    "_DISGUISED" => "",
	    "_BAILE" => "",
	    "_INCARNCATE" => "",
	    "CASTFORM_NORMAL" => "Castform",
	    "_OVERCAST" => "",
	    "_ALTERED" => "",
	    "_RED_STRIPED" => "",
	    "_WHITE_STRIPED" => "",
	    "_STANDARD" => "",
	    "DEERLING_SPRING" => "Deerling",
	    "SAWSBUCK_SPRING" => "Sawsbuck",
	    "MELOETTA_ARIA" => "Meloetta",
	    "_ORDINARY" => "",
	    "_MISC_INFO" => "",
	    "_INCARNATE" => "",
	    "_AVERAGE" => "",
	    "_NEUTRAL" => "",
	    "_50" => "",
	    "_PHONY" => "",
	    "EISCUE_ICE" => "Eiscue",
	    "_FULL_BELLY" => "",
	    "WISHIWASHI_SOLO" => "Wishiwashi",
	    "_SINGLE_STRIKE" => "",
	    "BASCULEGION_M" => "Basculegion",
	    "_SEGMENT" => "",
	    "_THREE" => "",
	    "_CHEST" => "",
	    "_GREEN" => "",
	    "_COUNTERFEIT" => "",
	    "_CURLY" => "",
	    "_UNREMARKABLE" => "",
	    "TERAPAGOS_NORMAL" => "Terapagos",
	    "_AMPED" => "",
	    "DIALGA_PRIMAL" => "Dialga Primal",
	    "PALKIA_PRIMAL" => "Palkia Primal"
	}

	

	if snake_case

		subs.each do |k,v|
			k = k.gsub("_", "").downcase
			species = species.gsub(/#{k}$/, v)
		end
	else
		subs.each do |k,v|
			species = species.gsub(k, v)
		end
	end


	species
end

# p species_sub("toxtricityamped", true)

def showdown_subs move
	subs = {
	    "Roar Of Time": "Roar of Time",
	    "U Turn": "U-turn",
	    "V Create": "V-create",
	    "Selfdestruct": "Self-Destruct",
	    "Self Destruct": "Self-Destruct",
	    "Soft Boiled": "Soft-Boiled",
	    "Will O Wisp": "Will-O-Wisp",
	    "Double Edge": "Double-Edge",
	    "Mud Slap": "Mud-Slap",
	    "Lock On": "Lock-On",
	    "Wake Up Slap": "Wake-Up Slap",
	    "X Scissor": "X-Scissor",
	    "Freeze Dry": "Freeze-Dry",
	    "Topsy Turvy": "Topsy-Turvy",
	    "Baby Doll Eyes": "Baby-Doll Eyes",
	    "Power Up Punch": "Power-Up Punch",
	    "Multi Attack": "Multi-Attack",
	    "Soul Heart": "Soul-Heart",
	    "Well Baked Body": "Well-Baked Body",
	    "Oraoraoraora": "ORAORAORAORA",
	    "Dragons Maw": "Dragon's Maw",
	    "Kings Shield": "King's Shield",
	    "Rks System": "RKS System",
	    "Thunderpunch": "Thunder Punch",
	    "Bubblebeam": "Bubble Beam",
	    "Doubleslap": "Double Slap",
	    "Solarbeam": "Solar Beam",
	    "Sonicboom": "Sonic Boom",
	    "Poisonpowder": "Poison Powder",
	    "Thundershock": "Thunder Shock",
	    "Ancientpower": "Ancient Power",
	    "Extremespeed": "Extreme Speed",
	    "Dragonbreath": "Dragon Breath",
	    "Dynamicpunch": "Dynamic Punch",
	    "Grasswhistle": "Grass Whistle",
	    "Featherdance": "Feather Dance",
	    "Faint Attack": "Feint Attack",
	    "Smellingsalt": "Smelling Salts",
	    "U-Turn": "U-turn",
	    "V-Create": "V-create",
	    "Sand-Attack": "Sand Attack",
	    "Softboiled": "Soft-Boiled",
	    "Vicegrip": "Vise Grip",
	    "Hi Jump Kick": "High Jump Kick",
	    "Double-edge": "Double-Edge",
	    "Lock-on": "Lock-On",
	    "Topsy-turvy": "Topsy-Turvy",
	    "Freeze-dry": "Freeze-Dry",
	    "Baby-doll Eyes": "Baby-Doll Eyes",
	    "Mud-slap": "Mud-Slap",
	    "X-scissor": "X-Scissor"
	}
	if subs[move.to_sym]
		subs[move.to_sym]
	else
		move
	end
end


# Do not create custom pokemon from this list because they are just extra alt forms
def showdown_ignore_list
	[
	"deoxysnormal",
	"wormadamplantcloak",
	"rotomcut",
	"shayminland",
	"aegislash",
	"hoopaconfined",
	"lycanrocmidday",
	"toxtricityamped",
	"urshifusinglestrike",
	"pichuspikyeared",
	"pikachustarter",
	"eeveestarter",
	"unownb",
	"unownc",
	"unownd",
	"unowne",
	"unownf",
	"unowng",
	"unownh",
	"unowni",
	"unownj",
	"unownk",
	"unownl",
	"unownm",
	"unownn",
	"unowno",
	"unownp",
	"unownq",
	"unownr",
	"unowns",
	"unownt",
	"unownu",
	"unownv",
	"unownw",
	"unownx",
	"unowny",
	"unownz",
	"unownexclamation",
	"unownquestion",
	"burmysandy",
	"burmytrash",
	"mothimsandy",
	"mothimtrash",
	"shelloseast",
	"gastrodoneast",
	"arceusnormal",
	"deerlingsummer",
	"deerlingautumn",
	"deerlingwinter",
	"sawsbucksummer",
	"sawsbuckautumn",
	"sawsbuckwinter",
	"greninjabattlebond",
	"scatterbugicysnow",
	"scatterbugpolar",
	"scatterbugtundra",
	"scatterbugcontinental",
	"scatterbuggarden",
	"scatterbugelegant",
	"scatterbugmeadow",
	"scatterbugmodern",
	"scatterbugmarine",
	"scatterbugarchipelago",
	"scatterbughighplains",
	"scatterbugsandstorm",
	"scatterbugriver",
	"scatterbugmonsoon",
	"scatterbugsavanna",
	"scatterbugsun",
	"scatterbugocean",
	"scatterbugjungle",
	"scatterbugfancy",
	"scatterbugpokeball",
	"spewpaicysnow",
	"spewpapolar",
	"spewpatundra",
	"spewpacontinental",
	"spewpagarden",
	"spewpaelegant",
	"spewpameadow",
	"spewpamodern",
	"spewpamarine",
	"spewpaarchipelago",
	"spewpahighplains",
	"spewpasandstorm",
	"spewpariver",
	"spewpamonsoon",
	"spewpasavanna",
	"spewpasun",
	"spewpaocean",
	"spewpajungle",
	"spewpafancy",
	"spewpapokeball",
	"vivillonicysnow",
	"vivillonpolar",
	"vivillontundra",
	"vivilloncontinental",
	"vivillongarden",
	"vivillonelegant",
	"vivillonmeadow",
	"vivillonmodern",
	"vivillonmarine",
	"vivillonarchipelago",
	"vivillonhighplains",
	"vivillonsandstorm",
	"vivillonriver",
	"vivillonmonsoon",
	"vivillonsavanna",
	"vivillonsun",
	"vivillonocean",
	"vivillonjungle",
	"flabebered",
	"flabebeyellow",
	"flabebeorange",
	"flabebeblue",
	"flabebewhite",
	"floettered",
	"floetteyellow",
	"floetteorange",
	"floetteblue",
	"floettewhite",
	"florgesred",
	"florgesyellow",
	"florgesorange",
	"florgesblue",
	"florgeswhite",
	"furfrounatural",
	"furfrouhearttrim",
	"furfroustartrim",
	"furfroudiamondtrim",
	"furfroudebutantetrim",
	"furfroumatrontrim",
	"furfroudandytrim",
	"furfroulareinetrim",
	"furfroukabukitrim",
	"furfroupharaohtrim",
	"xerneasactive",
	"zygardepowerconstruct",
	"zygarde10aurabreak",
	"zygarde10powerconstruct",
	"rockruffowntempo",
	"silvallynormal",
	"miniorcore",
	"miniormeteorred",
	"miniormeteororange",
	"miniormeteoryellow",
	"miniormeteorblue",
	"miniormeteorindigo",
	"miniormeteorviolet",
	"miniorcorered",
	"miniorcoreorange",
	"miniorcoreyellow",
	"miniorcoreblue",
	"miniorcoreindigo",
	"miniorcoreviolet",
	"alcremieregular",
	"alcremiestrawberryvanillacream",
	"alcremiestrawberryrubycream",
	"alcremiestrawberrymatchacream",
	"alcremiestrawberrymintcream",
	"alcremiestrawberrylemoncream",
	"alcremiestrawberrysaltedcream",
	"alcremiestrawberryrubyswirl",
	"alcremiestrawberrycaramelswirl",
	"alcremiestrawberryrainbowswirl",
	"alcremieberryvanillacream",
	"alcremieberryrubycream",
	"alcremieberrymatchacream",
	"alcremieberrymintcream",
	"alcremieberrylemoncream",
	"alcremieberrysaltedcream",
	"alcremieberryrubyswirl",
	"alcremieberrycaramelswirl",
	"alcremieberryrainbowswirl",
	"alcremielovevanillacream",
	"alcremieloverubycream",
	"alcremielovematchacream",
	"alcremielovemintcream",
	"alcremielovelemoncream",
	"alcremielovesaltedcream",
	"alcremieloverubyswirl",
	"alcremielovecaramelswirl",
	"alcremieloverainbowswirl",
	"alcremiestarvanillacream",
	"alcremiestarrubycream",
	"alcremiestarmatchacream",
	"alcremiestarmintcream",
	"alcremiestarlemoncream",
	"alcremiestarsaltedcream",
	"alcremiestarrubyswirl",
	"alcremiestarcaramelswirl",
	"alcremiestarrainbowswirl",
	"alcremieclovervanillacream",
	"alcremiecloverrubycream",
	"alcremieclovermatchacream",
	"alcremieclovermintcream",
	"alcremiecloverlemoncream",
	"alcremiecloversaltedcream",
	"alcremiecloverrubyswirl",
	"alcremieclovercaramelswirl",
	"alcremiecloverrainbowswirl",
	"alcremievanillacream",
	"alcremierubycream",
	"alcremiematchacream",
	"alcremiemintcream",
	"alcremielemoncream",
	"alcremiesaltedcream",
	"alcremierubyswirl",
	"alcremiecaramelswirl",
	"alcremierainbowswirl",
	"alcremieribbonvanillacream",
	"alcremieribbonrubycream",
	"alcremieribbonmatchacream",
	"alcremieribbonmintcream",
	"alcremieribbonlemoncream",
	"alcremieribbonsaltedcream",
	"alcremieribbonrubyswirl",
	"alcremieribboncaramelswirl",
	"alcremieribbonrainbowswirl",
	"palafinzero",
	"tatsugiridroopy",
	"tatsugiristretchy",
	"ogerponteal"]
end
