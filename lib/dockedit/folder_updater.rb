# frozen_string_literal: true

module DockEdit
  # Handles updating folder tile properties in the Dock plist.
  #
  # These helpers mutate existing folder tiles to change view and style
  # without recreating them.
  class FolderUpdater
    # Update the +showas+ value for an existing folder tile.
    #
    # @param folder_dict [REXML::Element] Folder tile `<dict>` element.
    # @param show_as [Integer] New show-as value (1=fan, 2=grid, 3=list, 4=auto).
    # @return [Boolean] +true+ if the value was updated or added.
    def self.update_folder_showas(folder_dict, show_as)
      update_folder_integer_key(folder_dict, 'showas', show_as)
    end

    # Update the +displayas+ value for an existing folder tile.
    #
    # @param folder_dict [REXML::Element] Folder tile `<dict>` element.
    # @param display_as [Integer] New display-as value (0=stack, 1=folder).
    # @return [Boolean] +true+ if the value was updated or added.
    def self.update_folder_displayas(folder_dict, display_as)
      update_folder_integer_key(folder_dict, 'displayas', display_as)
    end

    # Update an integer key inside folder tile-data.
    #
    # If the key already exists its integer value is replaced; otherwise a new
    # key/value pair is appended.
    #
    # @param folder_dict [REXML::Element] Folder tile `<dict>` element.
    # @param key_name [String] Name of the integer key inside +tile-data+.
    # @param value [Integer] New integer value to set.
    # @return [Boolean] +true+ if the value was updated or added, +false+ if
    #   no +tile-data+ section could be found.
    def self.update_folder_integer_key(folder_dict, key_name, value)
      tile_data = PlistReader.get_tile_data(folder_dict)
      return false unless tile_data

      # Find and update the key
      current_key = nil
      tile_data.elements.each do |elem|
        if elem.name == 'key' && elem.text == key_name
          current_key = elem
        elsif current_key && elem.name == 'integer'
          elem.text = value.to_s
          return true
        end
      end

      # If key doesn't exist, add it
      TileFactory.add_plist_key_value(tile_data, key_name, 'integer', value.to_s)
      true
    end
  end
end

