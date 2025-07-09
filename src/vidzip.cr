require "option_parser"
require "./vidzip/finder"
require "./vidzip/extractor"

module Vidzip
  VERSION = "0.1.2"

  def self.run(args : Array(String), stdout : IO = STDOUT, stderr : IO = STDERR)
    path : String? = nil
    extract = false
    show_help = false
    show_version = false

    parser = OptionParser.new do |p|
      p.banner = "Usage: vidzip [arguments] <file>"
      p.on("-v", "--version", "Show version") { show_version = true }
      p.on("-h", "--help", "Show this help") { show_help = true }
      p.on("-e", "--extract", "Extract the zip file") { extract = true }
      p.unknown_args do |remaining|
        path = remaining.first?
      end
    end

    begin
      parser.parse(args)
    rescue ex : OptionParser::InvalidOption
      stderr.puts ex.message
      stderr.puts parser
      return 1
    end

    if show_version
      stdout.puts VERSION
      return 0
    end

    if show_help
      stdout.puts parser
      return 0
    end

    if path_str = path
      begin
        finder = VidZip::Finder.new(path_str)
        if offset = finder.find_zip_offset
          stdout.puts "ZIP file found at offset: #{offset}"
          if extract
            output_path = File.basename(path_str, File.extname(path_str)) + ".zip"
            extractor = VidZip::Extractor.new(path_str, output_path)
            extractor.extract(offset)
            stdout.puts "Extracted to #{output_path}"
          end
        else
          stdout.puts "No ZIP file found."
        end
        return 0
      rescue e : VidZip::Finder::FileNotFoundError
        stderr.puts e.message
        return 1
      end
    else
      stderr.puts "Error: Missing file path."
      stderr.puts parser
      return 1
    end
  end
end

Vidzip.run(ARGV)
