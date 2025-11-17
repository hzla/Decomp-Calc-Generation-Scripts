require 'json'
require_relative 'helpers'



abils = File.read("../include/constants/abilities.h").split("\n")


ability_list = []


abils.each do |line|
	if line.include?("#define ABILITY_")
		ability_name = line.split("#define ABILITY_")[1].split(" ")[0]

		ability_name = format_name(ability_name, "ABILITY_")

		ability_index = line.split("#define ABILITY_")[1].split(" ")[1].to_i

		ability_list[ability_index] = ability_name
	end
end

p ability_list[186]