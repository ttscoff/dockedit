# frozen_string_literal: true

module DockEdit
  # Utility functions for parsing and formatting Dock-related values.
  module Parsers
    include Constants

    # Parse a show-as argument into an integer value.
    #
    # Accepts symbolic forms like "fan", "grid", "list", "auto" (and their
    # single-letter aliases) and returns the corresponding integer constant.
    #
    # @param value [String, nil] Raw user input.
    # @return [Integer, nil] Parsed show-as value, or +nil+ if +value+ is +nil+.
    def self.parse_show_as(value)
      return nil if value.nil?

      key = value.downcase
      SHOW_AS_VALUES[key] || 4
    end

    # Convert a numeric show-as value into a human-readable name.
    #
    # @param value [Integer] Numeric show-as value.
    # @return [String] One of "fan", "grid", "list", or "auto".
    def self.show_as_name(value)
      case value
      when 1 then 'fan'
      when 2 then 'grid'
      when 3 then 'list'
      when 4 then 'auto'
      else 'auto'
      end
    end

    # Parse a display-as argument into an integer value.
    #
    # Accepts "stack"/"s" and "folder"/"f".
    #
    # @param value [String, nil] Raw user input.
    # @return [Integer, nil] Parsed display-as value, or +nil+ if invalid or +nil+.
    def self.parse_display_as(value)
      return nil if value.nil?

      key = value.downcase
      DISPLAY_AS_VALUES[key]
    end

    # Convert a numeric display-as value into a human-readable name.
    #
    # @param value [Integer] Numeric display-as value.
    # @return [String] Either "stack" or "folder".
    def self.display_as_name(value)
      case value
      when 0 then 'stack'
      when 1 then 'folder'
      else 'stack'
      end
    end
  end
end

