# frozen_string_literal: true

module DockEdit
  # Handles reading and parsing Dock and app plist data.
  class PlistReader
    include Constants

    # Extract the +tile-data+ `<dict>` from a Dock tile `<dict>`.
    #
    # @param app_dict [REXML::Element] Tile `<dict>` element.
    # @return [REXML::Element, nil] The nested +tile-data+ dict, or +nil+.
    def self.get_tile_data(app_dict)
      current_key = nil
      app_dict.elements.each do |elem|
        if elem.name == 'key'
          current_key = elem.text
        elsif elem.name == 'dict' && current_key == 'tile-data'
          return elem
        end
      end
      nil
    end

    # Look up a string value in a tile-data `<dict>`.
    #
    # @param tile_data [REXML::Element] Tile-data `<dict>`.
    # @param key_name [String] Name of the key to retrieve.
    # @return [String, nil] The associated string value, or +nil+.
    def self.get_tile_value(tile_data, key_name)
      current_key = nil
      tile_data.elements.each do |elem|
        if elem.name == 'key'
          current_key = elem.text
        elsif current_key == key_name
          return elem.text if elem.name == 'string'
          return nil
        end
      end
      nil
    end

    # Extract the `_CFURLString` from the nested +file-data+ dict.
    #
    # @param tile_data [REXML::Element] Tile-data `<dict>`.
    # @return [String, nil] The URL string, or +nil+ if none is present.
    def self.get_file_data_url(tile_data)
      current_key = nil
      tile_data.elements.each do |elem|
        if elem.name == 'key'
          current_key = elem.text
        elsif elem.name == 'dict' && current_key == 'file-data'
          return get_tile_value(elem, '_CFURLString')
        end
      end
      nil
    end

    # Get the `persistent-apps` array from a Dock plist document.
    #
    # @param doc [REXML::Document]
    # @return [REXML::Element, nil] The `<array>` element, or +nil+.
    def self.get_persistent_apps(doc)
      get_plist_array(doc, 'persistent-apps')
    end

    # Get the `persistent-others` array from a Dock plist document.
    #
    # @param doc [REXML::Document]
    # @return [REXML::Element, nil] The `<array>` element, or +nil+.
    def self.get_persistent_others(doc)
      get_plist_array(doc, 'persistent-others')
    end

    # Get a named array from the Dock plist root `<dict>`.
    #
    # @param doc [REXML::Document]
    # @param array_name [String] Name of the array key.
    # @return [REXML::Element, nil] The `<array>` element, or +nil+.
    def self.get_plist_array(doc, array_name)
      root_dict = doc.root.elements['dict']
      return nil unless root_dict

      current_key = nil
      root_dict.elements.each do |elem|
        if elem.name == 'key'
          current_key = elem.text
        elsif elem.name == 'array' && current_key == array_name
          return elem
        end
      end

      nil
    end

    # Load and parse the Dock plist as XML.
    #
    # The file at {DockEdit::Constants::DOCK_PLIST} is converted to XML form
    # using +plutil+ before being read.
    #
    # @return [REXML::Document] Parsed Dock plist document.
    def self.load_dock_plist
      unless system("plutil -convert xml1 '#{DOCK_PLIST}' 2>/dev/null")
        $stderr.puts "Error: Failed to convert Dock plist to XML"
        exit 1
      end

      plist_content = File.read(DOCK_PLIST)
      REXML::Document.new(plist_content)
    end

    # Read and parse +Info.plist+ from an app bundle.
    #
    # The plist is copied to a temporary file and converted to XML before
    # parsing. Selected keys are extracted into a flat Ruby hash.
    #
    # @param app_path [String] Absolute path to an `.app` bundle.
    # @return [Hash, nil] Hash of plist keys to values, or +nil+ if the
    #   plist cannot be read.
    def self.read_app_info(app_path)
      info_plist = File.join(app_path, 'Contents', 'Info.plist')
      return nil unless File.exist?(info_plist)

      # Convert to XML and read
      temp_plist = "/tmp/dockedit_info_#{$$}.plist"
      FileUtils.cp(info_plist, temp_plist)
      system("plutil -convert xml1 '#{temp_plist}' 2>/dev/null")

      content = File.read(temp_plist)
      File.delete(temp_plist) if File.exist?(temp_plist)

      doc = REXML::Document.new(content)
      root_dict = doc.root.elements['dict']
      return nil unless root_dict

      info = {}
      current_key = nil

      root_dict.elements.each do |elem|
        if elem.name == 'key'
          current_key = elem.text
        elsif current_key
          case elem.name
          when 'string'
            info[current_key] = elem.text
          when 'array'
            # For arrays, get first string element
            first_string = elem.elements['string']
            info[current_key] = first_string.text if first_string
          end
          current_key = nil
        end
      end

      info
    end
  end
end

