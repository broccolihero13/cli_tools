require 'thor'
require 'json'
require 'csv'

class CsvToJsonCLI < Thor
  desc "convert FILE JSON_TEMPLATE", "Convert a CSV file to JSON using a template"
  method_option :has_headers, type: :boolean, default: true, desc: "Indicates if the CSV file has headers"
  method_option :key_column, type: :numeric, required: true, desc: "The column number to use as the key"
  method_option :customize_json, type: :string, default: '', desc: "Enable custom JSON structure"
  method_option :output, type: :string, default: nil, desc: "Enable custom JSON structure"

  def convert(file=nil)
    unless File.exist?(file)
      puts "Error: File #{file} does not exist."
      return
    end

    unless file.end_with?('.csv') || file.end_with?('.txt')
      puts "Error: File #{file} should have a '.csv' or '.txt' extension"
      return
    end
    
    csv_content = File.read(file, :encoding => 'utf-8')
    unless csv_content.valid_encoding?
      puts "Error: File #{file} is not UTF-8 encoded."
      return
    end

    key_column = options[:key_column] - 1
    customize_json = options[:customize_json]
    has_headers = options[:has_headers]
    default_output = File.basename(file, File.extname(file)) + ".json"
    output_file = options[:output] || default_output
  
    csv_data = CSV.parse(csv_content, headers: has_headers)
  
    json_data = {}
  
    unless customize_json == ''
      headers = csv_data.headers if has_headers
      csv_data.each do |row|
        json_row = customize_json.dup
  
        # Replace placeholders with values, adding quotes only for strings
        row.each_with_index do |(header, value), index|
          placeholder = "<col#{index + 1}>"
          # Add quotes only if the value is not a number
          puts('value:')
          puts(value)
          
          replacement = value.to_s.match?(/\A[-+]?\d*\.?\d+\Z/) ? value : "\"#{value}\""
          json_row.gsub!(placeholder, replacement)
        end
  
        begin
          row_json = JSON.parse(json_row) # Parse the resulting JSON string
          key = row[key_column] || row[headers[key_column]] # Use column index or header name
          json_data[key] = row_json
        rescue JSON::ParserError => e
          puts "Error: Invalid JSON template for row #{row.inspect}"
          puts "Details: #{e.message}"
          return
        end
      end
    else
      csv_data.each do |row|
        key = row[csv_data.headers[key_column].strip]
        json_data[key] = row.to_hash
      end
    end
  
    File.write(output_file, JSON.pretty_generate(json_data))
    puts "JSON output has been written to #{output_file}"
  end
  
  
  
end

CsvToJsonCLI.start(ARGV)
