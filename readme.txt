Requirements:

Install latest version of ruby

Put all files in this repo in a folder and place folder in the root pokeemerald-expansion directory
create an empty folder inside this folder named `output`

All parse scripts are to be run from inside this folder

To run an individual script run `ruby SCRIPT_NAME` ex: `ruby parse_mons.rb`

To generate a test calc run `ruby generate.rb`
This will run the scripts `parse_mons.rb`, `parse_moves.rb`, and `parse_sets.rb`
The data will then be formatted and output to Dynamic-Calc/backups/test.js
You calc can then be viewed by opening Dynamic-Calc/index.html in the browser

You will most likely need to modify/debug the scripts depending on how much you've changed pokeemerald expansion repo differs from the default one.

Expected debugging includes changing file paths and adjusting the string processing for extracting calc data.