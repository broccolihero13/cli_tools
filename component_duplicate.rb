require 'thor'
require 'colorize'

class ComponentDuplicateCLI < Thor
  def self.exit_on_failure?
    true
  end

  def help(*args)
    puts <<~HELP
      CSV-to-JSON Help:
      ---------------------------------
      duplicate JSX_CODE ITERATIONS
          Duplicate a JSX template or string a specified number of times.
      
    HELP

    puts "Example: ruby component_duplicate.rb duplicate 3 --input='<Section id=\"user<placeholder>\">\n<Table id=\"userTable<placeholder>\" rows={2}>\n<TableColumn id=\"subordinateNames<placeholder>\" width={20}/>\n<TableColumn id=\"subordinatePositions<placeholder>\" width={20}/>\n<TableColumn id=\"subordinatePayRates<placeholder>\" width={20}/>\n</Table>\n</Section>' --replacement=User".light_blue
    puts "Output: Duplicates the JSX template 3 times and replaces the placeholder with the number through each iteration. The output will return 3 multi-line blocks of JSX. It will also replace the regular iterator number with a string in of \"User\" in front of each placeholder so \"userUser1\" instead of \"user1\"".green

    puts "
    -------------------------------------------------
    "
    super
  end


  desc "duplicate JSX_CODE ITERATIONS", "Duplicate a JSX template a specified number of times"
  method_option :replacement, type: :string, desc: "String to replace placeholders in the template"
  method_option :output, type: :string, desc: "File to save the generated code"
  method_option :input, type: :string, desc: "Input string or file path containing the JSX template"

  def duplicate(iterations = 2)
    if ARGV.include?('-h') || ARGV.include?('--help')
      invoke :help, ['duplicate']
      return
    end

    iterations = iterations.to_i
    replacement = options[:replacement]

    if iterations <= 0
      puts "Error: Iterations must be a positive integer.".red
      return
    end

    if options[:input]
      if File.exist?(options[:input])
        jsx_code = File.read(options[:input])
      else
        jsx_code = options[:input].gsub('\n', "\n")
      end
    else
      puts "Error: Input is required via the --input option.".red
      return
    end

    generated_code = duplicate_jsx(jsx_code, iterations, replacement)

    if options[:output]
      File.write(options[:output], generated_code)
      puts "Generated code has been written to #{options[:output]}".green
    else
      puts "Generated Code:".yellow
      puts generated_code
    end
  end

  private

  def duplicate_jsx(template, iterations, replacement)
    result = []
    iterations.times do |i|
      code = template.dup
      if replacement
        code.gsub!("<placeholder>", "#{replacement}#{i + 1}")
      else
        code.gsub!("<placeholder>", "#{i + 1}")
      end
      result << code
    end
    result.join("\n")
  end
end

ComponentDuplicateCLI.start(ARGV)
