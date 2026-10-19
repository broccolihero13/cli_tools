require 'thor'
require 'csv'
require 'rubyXL'
require 'diff/lcs'
require 'colorize'
require_relative 'base_cli'

class CsvXlsxDiffCLI < BaseCLI
  def help(*args)
    puts <<~HELP
      CSV-XLSX-Diff Help:
      ---------------------------------
      diff FILE1 FILE2
          Compare two CSV or XLSX files and display the differences.

    HELP
    puts "Example 1 (Basic Diff): ruby csv_xlsx_diff.rb diff old.csv new.csv".light_blue
    puts "Example 2 (Sort and CSV Output): ruby csv_xlsx_diff.rb diff old.xlsx new.xlsx -s id -o csv --output-file results.csv".light_blue
    puts "\n-------------------------------------------------\n"
    super
  end

  desc "diff FILE1 FILE2", "Compare two CSV or XLSX files and display the differences"
  method_option :sort_by, type: :array, aliases: "-s", desc: "Columns to sort by before comparing (comma separated or multiple -s flags, e.g., -s 'Column 1' 'Column 2')"
  method_option :output_type, type: :string, aliases: "-o", default: "none", desc: "Type of output to generate: 'csv', 'xlsx', or 'none'"
  method_option :output_file, type: :string, desc: "Path to the output file (if output_type is 'csv' or 'xlsx')"

  def diff(file1=nil, file2=nil)
    check_help_for("diff")

    if file1.nil? || file2.nil?
      puts "Error: You must provide two files to compare.".red
      return
    end

    unless File.exist?(file1) && File.exist?(file2)
      puts "Error: Both files must exist.".red
      return
    end

    data1, headers1 = read_file(file1)
    data2, headers2 = read_file(file2)

    if data1.nil? || data2.nil?
      return
    end

    if options[:sort_by]
      data1 = sort_data(data1, headers1, options[:sort_by])
      data2 = sort_data(data2, headers2, options[:sort_by])
    end

    diffs = Diff::LCS.sdiff(data1, data2)

    if options[:output_type] == 'none'
      print_diffs(diffs, headers1, headers2)
    elsif options[:output_type] == 'csv'
      output_csv(diffs, headers1, headers2, options[:output_file] || "diff_output.csv")
    elsif options[:output_type] == 'xlsx'
      output_xlsx(diffs, headers1, headers2, options[:output_file] || "diff_output.xlsx")
    else
      puts "Error: Invalid output type. Please use 'csv', 'xlsx', or 'none'.".red
    end
  end

  private

  def read_file(file)
    ext = File.extname(file).downcase
    if ext == '.csv'
      read_csv(file)
    elsif ext == '.xlsx'
      read_xlsx(file)
    else
      puts "Error: Unsupported file type for #{file}. Only .csv and .xlsx are supported.".red
      return [nil, nil]
    end
  end

  def read_csv(file)
    begin
      csv = CSV.read(file, headers: true)
      [csv.map(&:to_h), csv.headers]
    rescue StandardError => e
      puts "Error reading CSV file #{file}: #{e.message}".red
      [nil, nil]
    end
  end

  def read_xlsx(file)
    begin
      workbook = RubyXL::Parser.parse(file)
      worksheet = workbook[0]
      data = []
      headers = worksheet[0].cells.map { |cell| cell&.value&.to_s }

      worksheet.each_with_index do |row, index|
        next if index == 0 # Skip headers
        next if row.nil?

        row_data = {}
        headers.each_with_index do |header, col_index|
          row_data[header] = row.cells[col_index]&.value&.to_s
        end
        data << row_data
      end
      [data, headers]
    rescue StandardError => e
      puts "Error reading XLSX file #{file}: #{e.message}".red
      [nil, nil]
    end
  end

  def sort_data(data, headers, sort_cols)
    invalid_cols = sort_cols - headers
    unless invalid_cols.empty?
      puts "Warning: Sort columns #{invalid_cols.join(', ')} not found in data.".yellow
    end

    valid_sort_cols = sort_cols & headers

    if valid_sort_cols.empty?
      return data
    end

    data.sort_by do |row|
      valid_sort_cols.map { |col| row[col].to_s }
    end
  end

  def print_diffs(diffs, headers1, headers2)
    all_headers = (headers1 + headers2).uniq
    has_diffs = false

    diffs.each do |change|
      case change.action
      when '+'
        has_diffs = true
        puts "ADDED:".green
        puts "  #{change.new_element.inspect}".green
      when '-'
        has_diffs = true
        puts "REMOVED:".red
        puts "  #{change.old_element.inspect}".red
      when '!'
        has_diffs = true
        puts "CHANGED:".yellow
        puts "  From: #{change.old_element.inspect}".red
        puts "  To:   #{change.new_element.inspect}".green

        all_headers.each do |header|
          old_val = change.old_element[header]
          new_val = change.new_element[header]
          if old_val != new_val
            puts "    #{header}: #{old_val.inspect} -> #{new_val.inspect}".yellow
          end
        end
      end
    end

    unless has_diffs
      puts "| UNCHANGED |".green
    end
  end

  def output_csv(diffs, headers1, headers2, output_file)
    all_headers = (headers1 + headers2).uniq
    csv_headers = ["Diff Action"] + all_headers

    CSV.open(output_file, "wb") do |csv|
      csv << csv_headers

      diffs.each do |change|
        case change.action
        when '+'
          row = ["ADDED"] + all_headers.map { |h| change.new_element[h] }
          csv << row
        when '-'
          row = ["REMOVED"] + all_headers.map { |h| change.old_element[h] }
          csv << row
        when '!'
          row_old = ["CHANGED (FROM)"] + all_headers.map { |h| change.old_element[h] }
          row_new = ["CHANGED (TO)"] + all_headers.map { |h| change.new_element[h] }
          csv << row_old
          csv << row_new
        end
      end
    end
    puts "CSV output saved to #{output_file}".green
  end

  def output_xlsx(diffs, headers1, headers2, output_file)
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    all_headers = (headers1 + headers2).uniq
    xlsx_headers = ["Row (F1 / F2)", "Status"] + all_headers

    xlsx_headers.each_with_index do |header, index|
      worksheet.add_cell(0, index, header)
    end

    row_index = 1
    diffs.each do |change|
      case change.action
      when '+'
        worksheet.add_cell(row_index, 0, "- / #{change.new_position + 2}")
        worksheet.add_cell(row_index, 1, "~ ADDED")
        all_headers.each_with_index { |h, i| worksheet.add_cell(row_index, i + 2, change.new_element[h]) }
        row_index += 1
      when '-'
        worksheet.add_cell(row_index, 0, "#{change.old_position + 2} / -")
        worksheet.add_cell(row_index, 1, "~ REMOVED")
        all_headers.each_with_index { |h, i| worksheet.add_cell(row_index, i + 2, change.old_element[h]) }
        row_index += 1
      when '!'
        worksheet.add_cell(row_index, 0, "#{change.old_position + 2} / #{change.new_position + 2}")
        worksheet.add_cell(row_index, 1, "~ MODIFIED")

        all_headers.each_with_index do |h, i|
          old_val = change.old_element[h]
          new_val = change.new_element[h]

          if old_val != new_val
            rich_text = RubyXL::RichText.new

            r1 = RubyXL::RichTextRun.new(t: RubyXL::Text.new(value: old_val.to_s + ' '))
            r1.r_pr = RubyXL::RunProperties.new
            r1.r_pr.color = RubyXL::Color.new(rgb: 'FFFF0000') # red
            r1.r_pr.strike = RubyXL::BooleanValue.new(val: true) # strikethrough!

            r2 = RubyXL::RichTextRun.new(t: RubyXL::Text.new(value: '→ '))

            r3 = RubyXL::RichTextRun.new(t: RubyXL::Text.new(value: new_val.to_s))
            r3.r_pr = RubyXL::RunProperties.new
            r3.r_pr.color = RubyXL::Color.new(rgb: 'FF00B050') # green

            rich_text.r = [r1, r2, r3]

            cell = worksheet.add_cell(row_index, i + 2, '')
            cell.is = rich_text
            cell.datatype = RubyXL::DataType::INLINE_STRING
          else
            worksheet.add_cell(row_index, i + 2, old_val)
          end
        end
        row_index += 1
      end
    end

    workbook.write(output_file)
    puts "XLSX output saved to #{output_file}".green
  end
end

CsvXlsxDiffCLI.start(ARGV) if $PROGRAM_NAME == __FILE__
