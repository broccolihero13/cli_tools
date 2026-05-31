require 'json'
require 'thor'
require 'colorize'
require 'diff/lcs'

class JsonDiff < Thor
  desc "diff FILE1 FILE2", "Compare two JSON files and display the differences"
  option :comparable, type: :string, aliases: "-c", desc: "The specific key to compare if you only want to diff a specific string field"
  option :threshold, type: :numeric, default: 50, aliases: "-t", desc: "The maximum number of lines to print in the console before saving to a file instead"
  option :char_limit, type: :numeric, default: 2000, aliases: "-l", desc: "The maximum number of characters to print in the console before saving to a file instead"
  option :output, type: :string, default: "diff_output.txt", aliases: "-o", desc: "The output file name if the diff is too big"

  def diff(file1, file2)
    unless File.exist?(file1)
      puts "Error: File not found - #{file1}".red
      return
    end

    unless File.exist?(file2)
      puts "Error: File not found - #{file2}".red
      return
    end

    begin
      json1 = JSON.parse(File.read(file1))
      json2 = JSON.parse(File.read(file2))
    rescue JSON::ParserError => e
      puts "Error parsing JSON files: #{e.message}".red
      return
    end

    @diff_lines = []
    comparable_key = options[:comparable]

    if comparable_key
      if json1.key?(comparable_key) && json2.key?(comparable_key)
        val1 = json1[comparable_key]
        val2 = json2[comparable_key]

        @current_key_diffs = []
        if json_string?(val1) && json_string?(val2)
          compare_objects(JSON.parse(val1), JSON.parse(val2), comparable_key)
        elsif val1.is_a?(String) && val2.is_a?(String)
          if react_string?(val1) && react_string?(val2)
            compare_strings(val1, val2, comparable_key)
          else
            compare_strings(val1, val2)
          end
        else
          compare_generic(val1, val2, comparable_key)
        end

        unless @current_key_diffs.empty?
          @diff_lines << "KEY: #{comparable_key}".cyan.bold
          @diff_lines << "--------------------------------------------------".cyan
          @diff_lines.concat(@current_key_diffs)
        end
        @current_key_diffs = nil
      else
        puts "Error: Key '#{comparable_key}' not found in both files.".red
        return
      end
    else
      if json1 == json2
        record_diff("| UNCHANGED |".green)
      elsif json1.is_a?(Hash) && json2.is_a?(Hash)
        all_keys = (json1.keys + json2.keys).uniq
        diffs_by_key = {}

        all_keys.each do |key|
          @current_key_diffs = []
          new_path = key.to_s
          
          if !json1.key?(key)
            record_diff("#{new_path} was added: #{json2[key].to_json}".green)
          elsif !json2.key?(key)
            record_diff("#{new_path} was removed: #{json1[key].to_json}".red)
          else
            compare_objects(json1[key], json2[key], new_path)
          end

          unless @current_key_diffs.empty?
            diffs_by_key[key] = @current_key_diffs
          end
        end
        @current_key_diffs = nil

        diffs_by_key.each_with_index do |(key, lines), index|
          if index > 0
            @diff_lines << ""
            @diff_lines << "==================================================".cyan
            @diff_lines << ""
          end
          @diff_lines << "KEY: #{key}".cyan.bold
          @diff_lines << "--------------------------------------------------".cyan
          @diff_lines.concat(lines)
        end
      else
        compare_objects(json1, json2)
      end
    end

    threshold = options[:threshold]
    char_limit = options[:char_limit]
    output_file = options[:output]

    diff_text = @diff_lines.join("\n")
    if @diff_lines.size > threshold || diff_text.length > char_limit
      clean_content = strip_colors(diff_text)
      begin
        File.write(output_file, clean_content)
        puts "Diff is too large (#{@diff_lines.size} lines, #{diff_text.length} characters). Output saved to: #{File.expand_path(output_file)}".yellow
      rescue StandardError => e
        puts "Error writing diff output to file: #{e.message}".red
        puts diff_text
      end
    else
      puts diff_text unless @diff_lines.empty?
    end
  end

  private

  def record_diff(line)
    if @current_key_diffs
      @current_key_diffs << line
    else
      @diff_lines << line
    end
  end

  def strip_colors(text)
    text.gsub(/\e\[[0-9;]*m/, "")
  end

  def json_string?(str)
    return false unless str.is_a?(String)
    trimmed = str.strip
    return false unless (trimmed.start_with?('{') && trimmed.end_with?('}')) || (trimmed.start_with?('[') && trimmed.end_with?(']'))
    
    begin
      JSON.parse(trimmed)
      true
    rescue JSON::ParserError
      false
    end
  end

  def react_string?(str)
    return false unless str.is_a?(String)
    trimmed = str.strip
    trimmed.start_with?('<') && (trimmed.end_with?('>') || trimmed.include?('</') || trimmed.include?('/>'))
  end

  def compare_strings(str1, str2, path = "")
    lines1 = str1.split("\n")
    lines2 = str2.split("\n")

    diffs = Diff::LCS.sdiff(lines1, lines2)
    
    path_prefix = path.to_s.empty? ? "" : "#{path} "
    
    grouped_changes = []
    current_group = nil

    diffs.each do |change|
      if change.action == '='
        if current_group
          grouped_changes << current_group
          current_group = nil
        end
        next
      end

      if current_group.nil?
        current_group = {
          action: change.action,
          start_old: change.old_position,
          end_old: change.old_position,
          start_new: change.new_position,
          end_new: change.new_position,
          old_elements: change.old_element ? [change.old_element] : [],
          new_elements: change.new_element ? [change.new_element] : []
        }
      else
        consecutive = false
        if change.action == current_group[:action]
          case change.action
          when '!'
            if change.old_position == current_group[:end_old] + 1 && change.new_position == current_group[:end_new] + 1
              consecutive = true
            end
          when '+'
            if change.new_position == current_group[:end_new] + 1
              consecutive = true
            end
          when '-'
            if change.old_position == current_group[:end_old] + 1
              consecutive = true
            end
          end
        end

        if consecutive
          current_group[:end_old] = change.old_position
          current_group[:end_new] = change.new_position
          current_group[:old_elements] << change.old_element if change.old_element
          current_group[:new_elements] << change.new_element if change.new_element
        else
          grouped_changes << current_group
          current_group = {
            action: change.action,
            start_old: change.old_position,
            end_old: change.old_position,
            start_new: change.new_position,
            end_new: change.new_position,
            old_elements: change.old_element ? [change.old_element] : [],
            new_elements: change.new_element ? [change.new_element] : []
          }
        end
      end
    end

    grouped_changes << current_group if current_group

    changes = []
    grouped_changes.each do |group|
      action = group[:action]
      case action
      when '!'
        line_label = group[:start_new] == group[:end_new] ? "line #{group[:start_new] + 1}" : "lines #{group[:start_new] + 1}-#{group[:end_new] + 1}"
        if group[:start_new] == group[:end_new] && group[:old_elements].first.length <= 100 && group[:new_elements].first.length <= 100
          old_wrapped = wrap_line(group[:old_elements].first)
          new_wrapped = wrap_line(group[:new_elements].first)
          changes << "#{path_prefix}#{line_label} - #{old_wrapped} -> WAS CHANGED TO -> #{new_wrapped}".yellow
        else
          old_wrapped_lines = group[:old_elements].map { |e| wrap_line(e) }
          new_wrapped_lines = group[:new_elements].map { |e| wrap_line(e) }
          changes << "#{path_prefix}#{line_label} changed from:\n#{old_wrapped_lines.map{|e| "  " + e.gsub("\n", "\n  ")}.join("\n")}\nto:\n#{new_wrapped_lines.map{|e| "  " + e.gsub("\n", "\n  ")}.join("\n")}".yellow
        end
      when '+'
        line_label = group[:start_new] == group[:end_new] ? "line #{group[:start_new] + 1}" : "lines #{group[:start_new] + 1}-#{group[:end_new] + 1}"
        verb = group[:start_new] == group[:end_new] ? "was added" : "were added"
        if group[:start_new] == group[:end_new] && group[:new_elements].first.length <= 100
          new_wrapped = wrap_line(group[:new_elements].first)
          changes << "#{path_prefix}#{line_label} - #{new_wrapped} #{verb}".green
        else
          new_wrapped_lines = group[:new_elements].map { |e| wrap_line(e) }
          changes << "#{path_prefix}#{line_label} #{verb}:\n#{new_wrapped_lines.map{|e| "  " + e.gsub("\n", "\n  ")}.join("\n")}".green
        end
      when '-'
        line_label = group[:start_old] == group[:end_old] ? "line #{group[:start_old] + 1}" : "lines #{group[:start_old] + 1}-#{group[:end_old] + 1}"
        verb = group[:start_old] == group[:end_old] ? "was removed" : "were removed"
        if group[:start_old] == group[:end_old] && group[:old_elements].first.length <= 100
          old_wrapped = wrap_line(group[:old_elements].first)
          changes << "#{path_prefix}#{line_label} - #{old_wrapped} #{verb}".red
        else
          old_wrapped_lines = group[:old_elements].map { |e| wrap_line(e) }
          changes << "#{path_prefix}#{line_label} #{verb}:\n#{old_wrapped_lines.map{|e| "  " + e.gsub("\n", "\n  ")}.join("\n")}".red
        end
      end
    end

    if changes.empty?
      record_diff("#{path_prefix}| UNCHANGED |".green)
    else
      changes.each_with_index do |change, index|
        record_diff("--------------------------------------------------") if index > 0
        record_diff(change)
      end
    end
  end

  def wrap_line(line, max_width = 100)
    return line if line.length <= max_width
    
    leading_space = line[/^\s*/]
    content = line[leading_space.length..-1]
    
    content_width = max_width - leading_space.length
    content_width = 20 if content_width < 20
    
    chunks = []
    temp_content = content
    while temp_content.length > content_width
      break_index = nil
      search_range = (content_width * 0.75).to_i..content_width
      
      search_range.to_a.reverse_each do |idx|
        if [' ', ',', ';', '{', '}', '(', ')', '[', ']'].include?(temp_content[idx])
          break_index = idx
          break
        end
      end
      
      break_index ||= content_width
      
      chunks << temp_content[0...break_index].rstrip
      temp_content = temp_content[break_index..-1].lstrip
    end
    chunks << temp_content unless temp_content.empty?
    
    chunks.map { |chunk| leading_space + chunk }.join("\n")
  end

  def compare_generic(val1, val2, key)
    if val1 == val2
      record_diff("| UNCHANGED |".green)
    else
      wrapped = wrap_line("#{val1.class} #{val1} | WAS CHANGED TO | #{val2}")
      record_diff(wrapped.yellow)
    end
  end

  def compare_objects(obj1, obj2, path = "")
    if obj1 == obj2
      record_diff("#{path} | UNCHANGED |".green) if path == ""
      return
    end

    if obj1.is_a?(Hash) && obj2.is_a?(Hash)
      all_keys = (obj1.keys + obj2.keys).uniq
      all_keys.each do |key|
        new_path = path.empty? ? key.to_s : "#{path}.#{key}"
        if !obj1.key?(key)
          wrapped = wrap_line("#{new_path} was added: #{obj2[key].to_json}")
          record_diff(wrapped.green)
        elsif !obj2.key?(key)
          wrapped = wrap_line("#{new_path} was removed: #{obj1[key].to_json}")
          record_diff(wrapped.red)
        else
          compare_objects(obj1[key], obj2[key], new_path)
        end
      end
    elsif obj1.is_a?(Array) && obj2.is_a?(Array)
      if obj1.length != obj2.length
        record_diff("#{path} length changed from #{obj1.length} to #{obj2.length}".yellow)
      end
      
      max_len = [obj1.length, obj2.length].max
      (0...max_len).each do |i|
        new_path = "#{path}[#{i}]"
        if i >= obj1.length
          wrapped = wrap_line("#{new_path} was added: #{obj2[i].to_json}")
          record_diff(wrapped.green)
        elsif i >= obj2.length
          wrapped = wrap_line("#{new_path} was removed: #{obj1[i].to_json}")
          record_diff(wrapped.red)
        else
          compare_objects(obj1[i], obj2[i], new_path)
        end
      end
    elsif obj1.is_a?(String) && obj2.is_a?(String)
      if json_string?(obj1) && json_string?(obj2)
        compare_objects(JSON.parse(obj1), JSON.parse(obj2), path)
      elsif react_string?(obj1) && react_string?(obj2)
        compare_strings(obj1, obj2, path)
      else
        wrapped = wrap_line("#{path} changed from #{obj1.to_json} to #{obj2.to_json}")
        record_diff(wrapped.yellow)
      end
    else
      wrapped = wrap_line("#{path} changed from #{obj1.to_json} to #{obj2.to_json}")
      record_diff(wrapped.yellow)
    end
  end
end

JsonDiff.start(ARGV) if $PROGRAM_NAME == __FILE__
