# frozen_string_literal: true

module DockEdit
  # Utility functions for handling user-supplied filesystem paths.
  module PathUtils
    include Constants

    # Expand a path shortcut or user path into a full filesystem path.
    #
    # Recognizes shortcuts such as "desktop", "downloads", "home", "~",
    # "applications", etc., falling back to +File.expand_path+.
    #
    # @param path [String] Raw path or shortcut.
    # @return [String] Expanded absolute path with trailing slash removed.
    def self.expand_path_shortcut(path)
      PATH_SHORTCUTS.each do |pattern, expanded|
        return expanded if path.match?(pattern)
      end
      # Not a shortcut, expand ~ and return
      File.expand_path(path).chomp('/')
    end

    # Determine whether the given path refers to a folder (not an app bundle).
    #
    # This respects path shortcuts and returns +true+ only for existing
    # directories that do not end in ".app".
    #
    # @param path [String] Raw path or shortcut.
    # @return [Boolean]
    def self.folder_path?(path)
      expanded = expand_path_shortcut(path)
      File.directory?(expanded) && !expanded.end_with?('.app')
    end

    # Check whether the given string looks like an explicit app bundle path.
    #
    # @param path [String]
    # @return [Boolean] +true+ if the string ends with ".app" and contains a '/'.
    def self.explicit_app_path?(path)
      path.end_with?('.app') && path.include?('/')
    end
  end
end

