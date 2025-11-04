Requirements:

Install latest version of ruby

Put all files in this repo in a folder and place folder in the root pokeemerald-expansion directory 

All parse scripts are to be run from inside the this folder

You must build your rom at least once so that `src/data/trainer_parties.h` is generated from the trainers.party file

To run a script run `ruby SCRIPT_NAME` ex: `ruby parse_mons.rb`



You will most likely need to modify the scripts depending on how much you've changed pokeemerald expansion repo differs from the default one.

Expected debugging includes changing file paths and adjusting the string processing for extracting calc data.