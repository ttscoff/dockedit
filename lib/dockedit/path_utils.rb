# frozen_string_literal: true

module DockEdit
  # Utility functions for path handling
  module PathUtils
    include Constants

    # Expand path shortcuts
    def self.expand_path_shortcut(path)
      PATH_SHORTCUTS.each do |pattern, expanded|
        return expanded if path.match?(pattern)
      end
      # Not a shortcut, expand ~ and return
      File.expand_path(path).chomp('/')
    end

    # Check if path is a folder (not an app)
    def self.folder_path?(path)
      expanded = expand_path_shortcut(path)
      File.directory?(expanded) && !expanded.end_with?('.app')
    end

    # Check if path is an explicit app path
    def self.explicit_app_path?(path)
      path.end_with?('.app') && path.include?('/')
    end
  end
end

