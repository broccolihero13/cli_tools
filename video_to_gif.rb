require 'thor'
require 'colorize'
require 'open3'
require_relative "base_cli"

class VideoToGifCLI < BaseCLI
  def help(*args)
    puts <<~HELP
      Video-to-GIF Help:
      ---------------------------------
      convert FILE
          Convert a video file to an animated GIF.

    HELP

    puts "Example: ruby video_to_gif.rb convert input.mp4".light_blue
    puts "Output: Prompts for options and converts 'input.mp4' to a GIF file.".green

    puts "
    -------------------------------------------------
    "
    super
  end

  desc "convert FILE", "Convert a video file to an animated GIF"
  method_option :output, aliases: '-o', type: :string, desc: "Output file name"

  def convert(file=nil)
    check_help_for("convert")

    unless file && File.exist?(file)
      puts "Error: File #{file.inspect} does not exist.".red
      return
    end

    valid_extensions = ['.mp4', '.mov', '.avi', '.webm']
    unless valid_extensions.include?(File.extname(file).downcase)
      puts "Error: File #{file} must be a valid video file (#{valid_extensions.join(', ')}).".red
      return
    end

    # Check if ffmpeg is installed (prefer Homebrew's ffmpeg-full if installed)
    ffmpeg_bin = find_ffmpeg
    unless ffmpeg_bin
      puts "Error: ffmpeg is not installed or not in your PATH.".red
      puts "Please install ffmpeg to use this tool.".yellow
      return
    end

    puts "Video to GIF Conversion Tool".green
    puts "---------------------------"

    # Prompt for options
    fps = ask("Enter framerate (fps) [default: 15]:")
    fps = "15" if fps.strip.empty?

    width = ask("Enter output width in pixels (e.g., 480). Aspect ratio will be maintained [default: 480]:")
    width = "480" if width.strip.empty?

    start_time = ask("Enter start time (in seconds or HH:MM:SS) [default: 0]:")
    start_time = "0" if start_time.strip.empty?

    duration = ask("Enter duration to convert (in seconds) [default: full video]:")

    custom_text = ""
    if drawtext_supported?(ffmpeg_bin)
      custom_text = ask("Enter custom text to overlay on the GIF [optional, default: none]:")
    end

    default_output = File.basename(file, File.extname(file)) + ".gif"
    output_file = options[:output] || ask("Enter output file name [default: #{default_output}]:")
    output_file = default_output if output_file.strip.empty?

    # Build the ffmpeg command
    # A standard high-quality gif conversion in ffmpeg often uses a palette for better color
    vf_filters = "fps=#{fps},scale=#{width}:-1:flags=lanczos"

    unless custom_text.strip.empty?
      # Escape single quotes and colons for ffmpeg drawtext filter
      escaped_text = custom_text.gsub("'") { "'\\\\\\''" }.gsub(":", "\\:")
      # Add text overlay centered at the bottom
      vf_filters += ",drawtext=text='#{escaped_text}':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=h-text_h-10"
    end

    vf_filters += ",split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"

    cmd = [ffmpeg_bin, "-y"]

    cmd += ["-ss", start_time] unless start_time == "0"
    cmd += ["-t", duration] unless duration.strip.empty?
    cmd += ["-i", file]
    cmd += ["-vf", vf_filters]
    cmd += ["-loop", "0", output_file]

    puts "Running ffmpeg...".light_blue
    # puts cmd.join(" ").dark_gray # don't have dark_gray in string colorize. Let's just do light_black or not colorize

    stdout_str, stderr_str, status = Open3.capture3(*cmd)

    if status.success?
      puts "Successfully converted #{file} to #{output_file}!".green
    else
      puts "Error occurred during conversion.".red
      puts stderr_str.yellow
    end
  end

  private

  def find_ffmpeg
    candidates = [
      "/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg",
      "/usr/local/opt/ffmpeg-full/bin/ffmpeg",
      "ffmpeg"
    ]
    candidates.find do |bin|
      if bin.start_with?("/")
        File.executable?(bin)
      else
        system("command -v #{bin} > /dev/null 2>&1")
      end
    end
  end

  def drawtext_supported?(ffmpeg_bin)
    system("#{ffmpeg_bin} -filters 2>/dev/null | grep -q drawtext")
  end
end

VideoToGifCLI.start(ARGV)
