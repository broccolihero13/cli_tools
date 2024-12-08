require 'thor'
require 'colorize'

class ComponentDuplicateCLI < Thor
  desc "duplicate JSX_CODE ITERATIONS", "Duplicate a JSX template a specified number of times"
  method_option :replacement, type: :string, desc: "String to replace placeholders in the template"
  method_option :output, type: :string, desc: "File to save the generated code"
  method_option :input, type: :string, desc: "Input string or file path containing the JSX template"

  def duplicate(iterations = 2)
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
