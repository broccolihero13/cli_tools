require 'thor'
require 'colorize'

class FileSearchCLI < Thor
  desc "search DIRECTORY_PATTERN SUBSTRING", "Recursively search for a SUBSTRING in files under directories matching DIRECTORY_PATTERN"
  method_option :output, type: :string, desc: "File to save the search results"
  method_option :ignore_case, type: :boolean, default: false, desc: "Ignore case during search"
  method_option :extensions, type: :string, desc: "Comma-separated list of file extensions to include (e.g., .rb,.txt)"
  method_option :exclude, type: :string, desc: "Comma-separated list of file or directory names to exclude"

  def search(directory_pattern, substring)
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
