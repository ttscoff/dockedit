#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to build a standalone, single-file version of dockedit

require 'fileutils'

LIB_DIR = File.join(__dir__, 'lib', 'dockedit')
OUTPUT_FILE = File.join(__dir__, 'dockedit')

# File order based on dependency order in lib/dockedit.rb
FILE_ORDER = %w[
  version.rb
  constants.rb
  matcher.rb
  path_utils.rb
  plist_reader.rb
  plist_writer.rb
  app_finder.rb
  tile_factory.rb
  folder_updater.rb
  parsers.rb
  dock.rb
  commands.rb
  cli.rb
].freeze

# Standard library requires from lib/dockedit.rb
STANDARD_REQUIRES = <<~RUBY
#!/usr/bin/env ruby
# frozen_string_literal: true

# dockedit - A script to edit the macOS Dock
# Usage: dockedit <subcommand> [options] [args]

require 'rexml/document'
require 'fileutils'
require 'optparse'
require 'uri'
require 'stringio'
RUBY

def remove_require_statements(content)
  # Remove require_relative statements (they're not needed in a single file)
  content.lines.reject { |line| line.strip.start_with?('require_relative') }.join
end

def build_standalone_file
  output = String.new
  output << STANDARD_REQUIRES
  output << "\n"

  FILE_ORDER.each do |filename|
    filepath = File.join(LIB_DIR, filename)
    unless File.exist?(filepath)
      warn "Warning: File #{filepath} not found"
      next
    end

    content = File.read(filepath)
    content = remove_require_statements(content)
    output << content
    output << "\n" unless content.end_with?("\n")
    output << "\n"
  end

  # Add main execution block
  output << <<~RUBY

if __FILE__ == $0
  DockEdit::CLI.run
end
RUBY

  output
end

def main
  standalone_content = build_standalone_file

  File.write(OUTPUT_FILE, standalone_content)
  FileUtils.chmod('+x', OUTPUT_FILE)

  puts "Standalone file generated: #{OUTPUT_FILE}"
  puts "File size: #{File.size(OUTPUT_FILE)} bytes"
end

main if __FILE__ == $0
