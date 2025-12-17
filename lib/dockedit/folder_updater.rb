# frozen_string_literal: true

module DockEdit
  # Handles updating folder tile properties
  class FolderUpdater
    # Update showas value for an existing folder tile
    def self.update_folder_showas(folder_dict, show_as)
      update_folder_integer_key(folder_dict, 'showas', show_as)
    end

    # Update displayas value for an existing folder tile
    def self.update_folder_displayas(folder_dict, display_as)
      update_folder_integer_key(folder_dict, 'displayas', display_as)
    end

    # Update an integer key in folder tile-data
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

