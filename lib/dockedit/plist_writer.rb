# frozen_string_literal: true

module DockEdit
  # Handles writing Dock plist data and restarting the Dock process.
  class PlistWriter
    include Constants

    # Write the modified Dock plist and restart the Dock.
    #
    # The provided document is pretty-printed, written to
    # {DockEdit::Constants::DOCK_PLIST}, converted back to binary format,
    # and the Dock process is restarted. Success messages are printed and
    # the process exits with status 0. On error, a message is printed and
    # the process exits with status 1.
    #
    # @param doc [REXML::Document] Modified Dock plist document.
    # @param success_messages [String, Array<String>] Message or messages to
    #   print after a successful write.
    # @return [void]
    def self.write_plist_and_restart(doc, success_messages)
      formatter = REXML::Formatters::Pretty.new(2)
      formatter.compact = true

      output = StringIO.new
      output << %{<?xml version="1.0" encoding="UTF-8"?>\n}
      output << %{<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n}
      formatter.write(doc.root, output)
      output << "\n"

      begin
        File.write(DOCK_PLIST, output.string)
      rescue => e
        $stderr.puts "Error: Failure to update Dock plist - #{e.message}"
        exit 1
      end

      # Convert back to binary and restart Dock
      unless system("plutil -convert binary1 '#{DOCK_PLIST}' 2>/dev/null")
        $stderr.puts "Error: Failure to update Dock plist"
        exit 1
      end

      system('killall Dock')

      # Handle single message or array of messages
      messages = success_messages.is_a?(Array) ? success_messages : [success_messages]
      messages.each { |msg| puts msg }
      exit 0
    end
  end
end

