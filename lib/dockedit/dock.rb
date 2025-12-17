# frozen_string_literal: true

module DockEdit
  # Main class for managing Dock state and high-level operations.
  #
  # A {Dock} instance wraps a parsed Dock plist and provides helpers for
  # locating and mutating app and folder tiles.
  class Dock
    attr_reader :doc, :apps_array, :others_array

    # Create a new Dock wrapper around the current Dock plist.
    #
    # The plist is loaded via {PlistReader.load_dock_plist} and the
    # `persistent-apps` and `persistent-others` arrays are extracted.
    #
    # @raise [SystemExit] Exits with status 1 if the arrays cannot be found.
    def initialize
      @doc = PlistReader.load_dock_plist
      @apps_array = PlistReader.get_persistent_apps(@doc)
      @others_array = PlistReader.get_persistent_others(@doc)

      unless @apps_array && @others_array
        $stderr.puts "Error: Could not find dock arrays in plist"
        exit 1
      end
    end

    # Persist changes to the Dock plist and restart the Dock.
    #
    # @param messages [String, Array<String>] Message or messages to print.
    # @return [void]
    def save(messages)
      PlistWriter.write_plist_and_restart(@doc, messages)
    end

    # Find an application tile by name or bundle identifier.
    #
    # @param query [String] Search term.
    # @return [Array<(Integer, String)>] A pair of `[index, display_name]`
    #   from the apps array, or `[nil, nil]` if not found.
    def find_app(query)
      app_dicts = @apps_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
      Matcher.find_app_index(app_dicts, query)
    end

    # Find a folder tile by name, bundle identifier, or path.
    #
    # @param query [String] Search term (name or path).
    # @param check_url [Boolean] Whether to match against the folder URL path.
    # @return [Array<(Integer, String)>] A pair of `[index, display_name]`
    #   from the folders array, or `[nil, nil]` if not found.
    def find_folder(query, check_url: false)
      folder_dicts = @others_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
      Matcher.find_item_index(folder_dicts, query, check_url: check_url)
    end

    # Find a tile in either the apps or folders section.
    #
    # Apps are searched first; if no match is found, folders are checked.
    #
    # @param query [String] Search term.
    # @param check_url [Boolean] Whether to match against folder URL paths.
    # @return [Array] A triple of `[array, element, display_name]`, or
    #   `[nil, nil, nil]` if nothing matches.
    def find_item(query, check_url: false)
      # Try apps first
      index, name = find_app(query)
      if index
        app_dicts = @apps_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
        return [@apps_array, app_dicts[index], name]
      end

      # Try folders
      index, name = find_folder(query, check_url: check_url)
      if index
        folder_dicts = @others_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
        return [@others_array, folder_dicts[index], name]
      end

      [nil, nil, nil]
    end

    # Return all app tile `<dict>` elements.
    #
    # @return [Array<REXML::Element>]
    def get_app_dicts
      @apps_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
    end

    # Return all folder tile `<dict>` elements.
    #
    # @return [Array<REXML::Element>]
    def get_folder_dicts
      @others_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
    end
  end
end

