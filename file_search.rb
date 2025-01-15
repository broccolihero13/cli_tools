require 'thor'
require 'colorize'

class FileSearchCLI < Thor
  def self.exit_on_failure?
    true
  end

  def help(*args)
    puts <<~HELP
      Search Help:
      ---------------------------------
      search DIRECTORY_PATTERN SUBSTRING
          Recursively search for a SUBSTRING in files matching DIRECTORY_PATTERN.
      
    HELP

    puts "Example: ruby file_search.rb search 'W*' \"UUID\" --extensions=\".js,.jsx\"  --exclude=\"v-1,metadata.js\" ".light_blue
    puts "Output: Searches for \"UUID\" in files with .js or .jsx extension under directories starting with 'W' and excluding files/directories with 'v-1' or 'metadata.js' in their name.\"".green

    puts "
    -------------------------------------------------
    "
    super
  end

  desc "search DIRECTORY_PATTERN SUBSTRING", "Recursively search for a SUBSTRING in files under directories matching DIRECTORY_PATTERN"
  method_option :output, type: :string, desc: "File to save the search results"
  method_option :ignore_case, type: :boolean, default: false, desc: "Ignore case during search"
  method_option :extensions, type: :string, desc: "Comma-separated list of file extensions to include (e.g., .rb,.txt)"
  method_option :exclude, type: :string, desc: "Comma-separated list of file or directory names to exclude"

  def search(directory_pattern, substring = nil)
    if ARGV.include?('-h') || ARGV.include?('--help')
      invoke :help, ['search']
      return
    end

    directories = Dir.glob(directory_pattern)
    if directories.empty?
      puts "Error: No directories match the pattern '#{directory_pattern}'.".red
      return
    end

    results = []
    extensions = options[:extensions]&.split(',')
    exclude_list = options[:exclude]&.split(',')

    directories.each do |directory|
      unless Dir.exist?(directory)
        puts "Skipping non-existent directory: #{directory}".yellow
        next
      end

      Dir.glob("#{escape_special_characters(directory)}/**/*").each do |file|
        next unless File.file?(file) # Skip directories
        next if exclude_list && exclude_list.any? { |ex| file.include?(ex) } # Skip excluded files/directories
        next if extensions && !extensions.include?(File.extname(file)) # Skip files not matching extensions

        File.foreach(file).with_index do |line, line_number|
          match = options[:ignore_case] ? line.downcase.include?(substring.downcase) : line.include?(substring)
          if match
            result = "#{file}:#{line_number + 1}: #{line.strip}"
            results << result
            puts result.yellow
          end
        end
      end
    end

    if results.empty?
      puts "No matches found for '#{substring}' in directories matching '#{directory_pattern}'.".red
    elsif options[:output]
      File.write(options[:output], results.join("\n"))
      puts "Results saved to '#{options[:output]}'.".green
    end
  end

  private

  # Escapes special characters but keeps valid glob patterns intact
  def escape_special_characters(path)
    path.gsub(/([\[\]\*\?\{\}])/, '\\\\\1')
  end
end

FileSearchCLI.start(ARGV)
