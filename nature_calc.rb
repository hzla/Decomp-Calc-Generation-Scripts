#!/usr/bin/env ruby

# Nature array with stat modifications
NATURE_ARRAY = [
  "Hardy", "Lonely", "Brave", "Adamant",
  "Naughty", "Bold", "Docile", "Relaxed",
  "Impish", "Lax", "Timid",
  "Hasty", "Serious", "Jolly", "Naive",
  "Modest", "Mild", "Quiet", "Bashful",
  "Rash", "Calm", "Gentle",
  "Sassy", "Careful", "Quirky"
]

# ASCII conversion table
ASCII_TABLE = {
  ' ' => 0, 'A' => 187, 'B' => 188, 'C' => 189, 'D' => 190, 'E' => 191, 'F' => 192,
  'G' => 193, 'H' => 194, 'I' => 195, 'J' => 196, 'K' => 197, 'L' => 198, 'M' => 199,
  'N' => 200, 'O' => 201, 'P' => 202, 'Q' => 203, 'R' => 204, 'S' => 205, 'T' => 206,
  'U' => 207, 'V' => 208, 'W' => 209, 'X' => 210, 'Y' => 211, 'Z' => 212, 'a' => 213,
  'b' => 214, 'c' => 215, 'd' => 216, 'e' => 217, 'f' => 218, 'g' => 219, 'h' => 220,
  'i' => 221, 'j' => 222, 'k' => 223, 'l' => 224, 'm' => 225, 'n' => 226, 'o' => 227,
  'p' => 228, 'q' => 229, 'r' => 230, 's' => 231, 't' => 232, 'u' => 233, 'v' => 234,
  'w' => 235, 'x' => 236, 'y' => 237, 'z' => 238, '2' => 163, '-' => 174, '♂' => 181,
  '♀' => 182, ":" => 240
}

def get_ascii_value(char)
  ASCII_TABLE[char] || 0
end

UNOWN_LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?"

def unown_table(value)
  UNOWN_LETTERS[value % 28] || 'A'
end

def unown_check(decimal_number)
  binary_pvalue = decimal_number.to_s(2).rjust(32, '0')
  binary_composite = binary_pvalue[6,2] + 
                    binary_pvalue[14,2] + 
                    binary_pvalue[22,2] + 
                    binary_pvalue[30,2]
  decimal_unown = binary_composite.to_i(2)
  unown_table(decimal_unown % 28)
end

def calculate_nature(trainer_name, pokemon_list, type)
  trainer_hash = 0
  pokemon_hash = 0  # Moved outside the loop but will be reset each iteration
  results = []
  accumulated_hash = 0
  # Calculate trainer hash
  trainer_name.upcase.each_char do |char|
    trainer_hash += get_ascii_value(char)
  end

  # Calculate nature for each Pokemon
  pokemon_list.each do |pokemon|
    pokemon_hash = accumulated_hash  # Reset pokemon_hash for each new Pokemon
    pokemon_name = pokemon.upcase

    # Calculate Pokemon hash
    pokemon_name.each_char do |char|
      pokemon_hash += get_ascii_value(char)
    end

    total_hash = pokemon_hash + trainer_hash
    accumulated_hash = total_hash
    personality_value = (total_hash * 256) + type.to_i
    nature_index = personality_value % 25

    result = NATURE_ARRAY[nature_index]


    results.push(result)
  end
  results[-1]
end

# # Main execution
# if ARGV.length < 2
#   puts "Usage: ruby nature_calc.rb <trainer_name> <pokemon1> [pokemon2] [pokemon3] [pokemon4] [pokemon5] [pokemon6] [type]"
#   exit(1)
# end

# trainer_name = ARGV[0]
# pokemon_list = ARGV[1..-2].compact # Get up to 6 Pokemon names
# type = ARGV[-1]

# results = calculate_nature(trainer_name, pokemon_list, type)
# results.each { |result| puts result }