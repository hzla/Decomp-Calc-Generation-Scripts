require_relative 'helpers'
require 'json'

tms = File.read("../include/constants/tms_hms.h").split("\n")


move_cat = "tms"

tm_numbers = {}
tm_numbers["tms"] = {}
tm_numbers["hms"] = {}

counts = {}
counts["tms"] = 0
counts["hms"] = 0

tms.each do |line|
	line = line.strip

	if line.start_with?("#define FOREACH_HM")
		move_cat = "hms"
	end

	if line.start_with?("F(")
		counts[move_cat] += 1

		move = format_move_name(line.match(/\((.*?)\)/)[1].downcase)
		tm_numbers[move_cat][move] = counts[move_cat]
	end
end 

File.write("./output/tms.json", JSON.pretty_generate(tm_numbers))


