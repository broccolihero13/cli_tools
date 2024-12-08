# cli_tools
Ruby CLI tools using Thor to help with common tasks

# csv_to_json.rb
## Convert command syntax
1. Standard CSV to JSON without custom JSON structure `ruby csv_to_json.rb convert sample.csv --key-column=1`
1. Name the output file `ruby csv_to_json.rb convert sample.csv --key-column=1 --output=outputname.json`
1. Inlcude a custom JSON structure `ruby csv_to_json.rb convert sample.csv --key-column=1 --customize-json='{"name": <col1>, "age": <col2>, "age2": <col2>}'`
### recommended alias
Add this as an alias for your terminal
`alias csvToJson="ruby ~/<full>/<path>/<to>/cli_tools/csv_to_json.rb convert"`
