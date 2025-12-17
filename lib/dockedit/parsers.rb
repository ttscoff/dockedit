# frozen_string_literal: true

module DockEdit
  # Utility functions for parsing and formatting values
  module Parsers
    include Constants

    # Parse show-as argument
    def self.parse_show_as(value)
      return nil if value.nil?

      key = value.downcase
      SHOW_AS_VALUES[key] || 4
    end

    # Get human-readable name for show-as value
    def self.show_as_name(value)
      case value
      when 1 then 'fan'
      when 2 then 'grid'
      when 3 then 'list'
      when 4 then 'auto'
      else 'auto'
      end
    end

    # Parse display-as argument
    def self.parse_display_as(value)
      return nil if value.nil?

      key = value.downcase
      DISPLAY_AS_VALUES[key]
    end

    # Get human-readable name for display-as value
    def self.display_as_name(value)
      case value
      when 0 then 'stack'
      when 1 then 'folder'
      else 'stack'
      end
    end
  end
end

