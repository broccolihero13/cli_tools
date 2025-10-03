require 'thor'
require 'colorize'
require_relative "base_cli"

class JSXParser < BaseCLI
  def help(*args)
    puts <<~HELP
      Common IDs Help:
      ---------------------------------
      common_ids FILE1 FILE2
          Finds common ID props in two JSX files.
      
    HELP

    puts "Example: ruby common_ids.rb common_ids sample1.jsx sample2.jsx".light_blue
    puts "Output: Terminal output with a list of the common IDs between the two files.".green

    puts "
    -------------------------------------------------
    "
    super
  end

  desc "common_ids FILE1 FILE2", "Finds common ID props in two JSX files"
  option :exclude, type: :array, default: [], desc: "List of substrings to exclude IDs that start with them"
  option :help, type: :boolean, aliases: "-h", desc: "Show help for this command"
  
  def common_ids(file1=nil, file2=nil)
    check_help_for("common_ids")

    if file1.nil? || file2.nil?
      puts "Error: Please provide two file names.".red
      return
    end

    if !File.exist?(file1) || !File.exist?(file2)
      puts "Error: One or both files do not exist.".red
      return
    end

    ids1 = extract_ids(file1, options[:exclude])
    ids2 = extract_ids(file2, options[:exclude])

    common = ids1 & ids2

    if common.any? && options[:exclude].any?
      puts "Common IDs found (excluding: #{options[:exclude]}):"
      puts common.join("\n")
    elsif common.any?
      puts "Common IDs found:"
      puts common.join("\n")
    else
      puts "No common IDs found."
    end
  end

  private

  def extract_ids(file, exclude_patterns)
    ids = []
    File.foreach(file) do |line|
      extracted_ids = line.scan(/id=["']([^"']+)["']/).flatten
      filtered_ids = extracted_ids.reject do |id|
        exclude_patterns.any? { |pattern| id.start_with?(pattern) }
      end
      ids.concat(filtered_ids)
    end
    ids
  end
end

JSXParser.start(ARGV)
