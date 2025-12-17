# frozen_string_literal: true

module DockEdit
  # Main class for managing Dock state and operations
  class Dock
    attr_reader :doc, :apps_array, :others_array

    def initialize
      @doc = PlistReader.load_dock_plist
      @apps_array = PlistReader.get_persistent_apps(@doc)
      @others_array = PlistReader.get_persistent_others(@doc)

      unless @apps_array && @others_array
        $stderr.puts "Error: Could not find dock arrays in plist"
        exit 1
      end
    end

    def save(messages)
      PlistWriter.write_plist_and_restart(@doc, messages)
    end

    def find_app(query)
      app_dicts = @apps_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
      Matcher.find_app_index(app_dicts, query)
    end

    def find_folder(query, check_url: false)
      folder_dicts = @others_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
      Matcher.find_item_index(folder_dicts, query, check_url: check_url)
    end

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

    def get_app_dicts
      @apps_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
    end

    def get_folder_dicts
      @others_array.elements.to_a.select { |e| e.is_a?(REXML::Element) && e.name == 'dict' }
    end
  end
end

