# frozen_string_literal: true

module DockEdit
  # Factory for creating dock tile elements
  class TileFactory
    # Create a spacer tile element
    def self.create_spacer_tile(small: false)
      tile_type = small ? 'small-spacer-tile' : 'spacer-tile'

      spacer = REXML::Element.new('dict')

      key1 = REXML::Element.new('key')
      key1.text = 'tile-data'
      spacer.add(key1)

      tile_data = REXML::Element.new('dict')
      label_key = REXML::Element.new('key')
      label_key.text = 'file-label'
      tile_data.add(label_key)
      label_string = REXML::Element.new('string')
      label_string.text = ''
      tile_data.add(label_string)
      spacer.add(tile_data)

      key2 = REXML::Element.new('key')
      key2.text = 'tile-type'
      spacer.add(key2)

      type_string = REXML::Element.new('string')
      type_string.text = tile_type
      spacer.add(type_string)

      spacer
    end

    # Create an app tile element
    def self.create_app_tile(app_path, app_info)
      app_dict = REXML::Element.new('dict')

      # tile-data key
      td_key = REXML::Element.new('key')
      td_key.text = 'tile-data'
      app_dict.add(td_key)

      # tile-data dict
      tile_data = REXML::Element.new('dict')

      # bundle-identifier
      add_plist_key_value(tile_data, 'bundle-identifier', 'string', app_info['CFBundleIdentifier'])

      # dock-extra
      add_plist_key_value(tile_data, 'dock-extra', 'false', nil)

      # file-data dict
      fd_key = REXML::Element.new('key')
      fd_key.text = 'file-data'
      tile_data.add(fd_key)

      file_data = REXML::Element.new('dict')
      add_plist_key_value(file_data, '_CFURLString', 'string', "file://#{URI.encode_www_form_component(app_path).gsub('%2F', '/')}/")
      add_plist_key_value(file_data, '_CFURLStringType', 'integer', '15')
      tile_data.add(file_data)

      # file-label
      label = app_info['CFBundleName'] || app_info['CFBundleDisplayName'] || File.basename(app_path, '.app')
      add_plist_key_value(tile_data, 'file-label', 'string', label)

      # file-mod-date
      add_plist_key_value(tile_data, 'file-mod-date', 'integer', '0')

      # file-type
      add_plist_key_value(tile_data, 'file-type', 'integer', '41')

      # is-beta
      add_plist_key_value(tile_data, 'is-beta', 'false', nil)

      # parent-mod-date
      add_plist_key_value(tile_data, 'parent-mod-date', 'integer', '0')

      app_dict.add(tile_data)

      # tile-type key
      tt_key = REXML::Element.new('key')
      tt_key.text = 'tile-type'
      app_dict.add(tt_key)

      tt_value = REXML::Element.new('string')
      tt_value.text = 'file-tile'
      app_dict.add(tt_value)

      app_dict
    end

    # Create a folder tile element
    def self.create_folder_tile(folder_path, show_as: 4, display_as: 1)
      folder_dict = REXML::Element.new('dict')

      # tile-data key
      td_key = REXML::Element.new('key')
      td_key.text = 'tile-data'
      folder_dict.add(td_key)

      # tile-data dict
      tile_data = REXML::Element.new('dict')

      # arrangement (0 = by name)
      add_plist_key_value(tile_data, 'arrangement', 'integer', '0')

      # displayas (0 = stack, 1 = folder)
      add_plist_key_value(tile_data, 'displayas', 'integer', display_as.to_s)

      # file-data dict
      fd_key = REXML::Element.new('key')
      fd_key.text = 'file-data'
      tile_data.add(fd_key)

      file_data = REXML::Element.new('dict')
      encoded_path = URI.encode_www_form_component(folder_path).gsub('%2F', '/')
      add_plist_key_value(file_data, '_CFURLString', 'string', "file://#{encoded_path}/")
      add_plist_key_value(file_data, '_CFURLStringType', 'integer', '15')
      tile_data.add(file_data)

      # file-label
      label = File.basename(folder_path)
      add_plist_key_value(tile_data, 'file-label', 'string', label)

      # file-mod-date
      add_plist_key_value(tile_data, 'file-mod-date', 'integer', '0')

      # file-type
      add_plist_key_value(tile_data, 'file-type', 'integer', '2')

      # parent-mod-date
      add_plist_key_value(tile_data, 'parent-mod-date', 'integer', '0')

      # preferreditemsize (-1 = default)
      add_plist_key_value(tile_data, 'preferreditemsize', 'integer', '-1')

      # showas (1=fan, 2=grid, 3=list, 4=auto)
      add_plist_key_value(tile_data, 'showas', 'integer', show_as.to_s)

      folder_dict.add(tile_data)

      # tile-type key
      tt_key = REXML::Element.new('key')
      tt_key.text = 'tile-type'
      folder_dict.add(tt_key)

      tt_value = REXML::Element.new('string')
      tt_value.text = 'directory-tile'
      folder_dict.add(tt_value)

      folder_dict
    end

    # Helper to add key/value pair to plist dict
    def self.add_plist_key_value(dict, key_name, value_type, value)
      key = REXML::Element.new('key')
      key.text = key_name
      dict.add(key)

      val_elem = REXML::Element.new(value_type)
      val_elem.text = value if value
      dict.add(val_elem)
    end
  end
end

