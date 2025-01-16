require 'httparty'
require 'csv'
require 'json'
require 'thor'
require 'colorize'

class ApiCaller < Thor
  def self.exit_on_failure?
    true
  end

  def help(*args)
    puts <<~HELP
      API Call Looper Help:
      ---------------------------------
      loop INPUT_FILE OUTPUT_FILE
          Loop through a CSV file and make API calls for each row.
      
    HELP

    puts "Example: ruby api_looper.rb loop apiCSVTest.csv attribute_call_results.csv".light_blue
    puts "Output: Results saved to a file called `attribute_call_results.csv`".green

    puts "
    -------------------------------------------------
    "
    super
  end

  desc "loop INPUT_FILE OUTPUT_FILE", "Processes the INPUT_FILE CSV and outputs results to OUTPUT_FILE"
  method_option :access_token, aliases: '-t', type: :string, desc: "Access token for API calls (optional)"

  def loop(input_file, output_file="output.csv")
    if ARGV.include?('-h') || ARGV.include?('--help')
      invoke :help, ['loop']
      return
    end
    token = options[:access_token] || ask("Enter access token (leave blank if none):")

    results = []

    if !File.exist?(input_file) || !input_file.end_with?('.csv')
      puts "Error: Input file #{input_file} does not exist or is not a CSV file.".red
      return
    end

    csv_headers = CSV.open(input_file, 'r', &:readline)
    unless csv_headers.include?('method') && csv_headers.include?('endpoint')
      puts "Error: Input file must include 'method' and 'endpoint' headers.".red
      return
    end

    options = { headers: true, liberal_parsing: true }
    CSV.foreach(input_file, **options) do |row|
      method = row['method']
      endpoint = row['endpoint']
      payload = row['payload']
      
      puts("Row's payload is: #{payload}") # Debugging output
    
      if payload
        begin
          parsed_payload = JSON.parse(payload)
          puts("Parsed payload: #{parsed_payload}")
        rescue JSON::ParserError => e
          puts("Failed to parse payload: #{e.message}")
        end
      else
        puts("No payload found for row")
      end

      result = make_api_call(method, endpoint, parsed_payload, token)
      results << {
        method: method,
        endpoint: endpoint,
        timestamp: result[:timestamp],
        status: result[:status],
        response_body: result[:body]
      }
    end

    CSV.open(output_file, "w") do |csv|
      csv << ["method", "endpoint", "timestamp", "status", "response_body"]
      results.each do |result|
        csv << [result[:method], result[:endpoint], result[:timestamp], result[:status], result[:response_body]]
      end
    end
    puts "Results saved to #{output_file}"
  end

  private

  def make_api_call(method, endpoint, payload, token)
    options = { headers: {} }
    options[:headers]["Authorization"] = "Bearer #{token}" unless token.empty?
    options[:body] = payload unless payload.empty?

    response = nil
    begin
      case method.downcase
      when 'get'
        response = HTTParty.get(endpoint, options)
      when 'post'
        response = HTTParty.post(endpoint, options)
      when 'put'
        response = HTTParty.put(endpoint, options)
      when 'delete'
        response = HTTParty.delete(endpoint, options)
      else
        raise "Unsupported method: #{method}"
      end
    rescue StandardError => e
      response = { status: "Error", body: e.message }
    end

    {
      timestamp: Time.now.utc,
      status: response.code || "Error",
      body: response.body || response[:body]
    }
  end
end

ApiCaller.start(ARGV)
