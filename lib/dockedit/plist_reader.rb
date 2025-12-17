# frozen_string_literal: true

module DockEdit
  # Handles reading and parsing plist data
  class PlistReader
    include Constants

    # Get tile-data dict from app dict
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

    # Get a string value from tile-data
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

    # Get _CFURLString from file-data dict
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

    # Get the persistent-apps array from the plist
    def self.get_persistent_apps(doc)
      get_plist_array(doc, 'persistent-apps')
    end

    # Get the persistent-others array from the plist
    def self.get_persistent_others(doc)
      get_plist_array(doc, 'persistent-others')
    end

    # Get a named array from the plist root dict
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

    # Load and parse dock plist
    def self.load_dock_plist
      unless system("plutil -convert xml1 '#{DOCK_PLIST}' 2>/dev/null")
        $stderr.puts "Error: Failed to convert Dock plist to XML"
        exit 1
      end

      plist_content = File.read(DOCK_PLIST)
      REXML::Document.new(plist_content)
    end

    # Read Info.plist from an app bundle
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

