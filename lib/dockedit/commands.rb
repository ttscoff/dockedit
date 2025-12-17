# frozen_string_literal: true

module DockEdit
  # Command handlers for dockedit subcommands
  module Commands
    # Insert space subcommand
    def self.space(args)
      options = { small: false, after: [] }

      parser = CLI.space_parser(options)
      parser.order!(args)

      small = options[:small]
      after_apps = options[:after]
      spacer_type = small ? 'Small space' : 'Space'

      dock = Dock.new
      messages = []

      if after_apps.empty?
        # Add single space at end
        spacer = TileFactory.create_spacer_tile(small: small)
        dock.apps_array.add(spacer)
        messages << "#{spacer_type} added to end of Dock."
      else
        # Process each --after app
        after_apps.each do |after_app|
          # Re-fetch app_dicts each time since array changes after insert
          app_dicts = dock.get_app_dicts

          index, name = dock.find_app(after_app)
          unless index
            $stderr.puts "Error: App '#{after_app}' not found in Dock"
            exit 1
          end

          spacer = TileFactory.create_spacer_tile(small: small)
          dock.apps_array.insert_after(app_dicts[index], spacer)
          messages << "#{spacer_type} inserted after '#{name}'."
        end
      end

      dock.save(messages)
    end

    # Add app/folder subcommand
    def self.add(args)
      options = { after: nil, show_as: nil, display_as: nil }

      parser = CLI.add_parser(options)
      parser.permute!(args)

      after_target = options[:after]
      show_as = options[:show_as]
      display_as = options[:display_as]

      if args.empty?
        $stderr.puts parser
        exit 1
      end

      dock = Dock.new
      messages = []
      last_inserted_app_element = nil
      last_inserted_folder_element = nil

      # Find initial insertion point if --after specified
      if after_target
        after_array, after_element, _after_name = dock.find_item(after_target, check_url: true)

        if after_element
          if after_array == dock.apps_array
            last_inserted_app_element = after_element
          else
            last_inserted_folder_element = after_element
          end
        else
          $stderr.puts "Error: '#{after_target}' not found in Dock"
          exit 1
        end
      end

      # Process each argument
      args.each do |item_query|
        # Determine if this is a folder or app
        if PathUtils.folder_path?(item_query)
          # It's a folder
          folder_path = PathUtils.expand_path_shortcut(item_query)

          unless File.directory?(folder_path)
            $stderr.puts "Error: Folder '#{folder_path}' not found"
            exit 1
          end

          folder_name = File.basename(folder_path)

          # Check if folder is already in dock
          existing_index, existing_name = dock.find_folder(folder_path, check_url: true)

          if existing_index
            # If show_as or display_as was specified, update the existing folder
            updates = []
            folder_dicts = dock.get_folder_dicts
            if show_as
              FolderUpdater.update_folder_showas(folder_dicts[existing_index], show_as)
              updates << "view=#{Parsers.show_as_name(show_as)}"
            end
            if display_as
              FolderUpdater.update_folder_displayas(folder_dicts[existing_index], display_as)
              updates << "style=#{Parsers.display_as_name(display_as)}"
            end

            if updates.any?
              messages << "'#{existing_name}' updated (#{updates.join(', ')})."
            else
              $stderr.puts "Warning: '#{existing_name}' is already in the Dock, skipping"
            end
            next
          end

          # Create the folder tile (use defaults if not specified)
          folder_tile = TileFactory.create_folder_tile(folder_path, show_as: show_as || 4, display_as: display_as || 1)

          if last_inserted_folder_element
            dock.others_array.insert_after(last_inserted_folder_element, folder_tile)
          else
            dock.others_array.add(folder_tile)
          end

          last_inserted_folder_element = folder_tile
          messages << "'#{folder_name}' folder added to Dock."

        elsif PathUtils.explicit_app_path?(item_query)
          # Explicit app path given
          app_path = File.expand_path(item_query)

          unless File.exist?(File.join(app_path, 'Contents', 'Info.plist'))
            $stderr.puts "Error: Application path '#{app_path}' not found"
            exit 1
          end

          app_info = PlistReader.read_app_info(app_path)
          unless app_info && app_info['CFBundleIdentifier']
            $stderr.puts "Error: Could not read app info from '#{app_path}'"
            exit 1
          end

          app_name = app_info['CFBundleName'] || app_info['CFBundleDisplayName'] || File.basename(app_path, '.app')

          # Check if app is already in dock
          existing_index, existing_name = dock.find_app(app_info['CFBundleIdentifier'])

          if existing_index
            $stderr.puts "Warning: '#{existing_name}' is already in the Dock, skipping"
            next
          end

          # Create the app tile
          app_tile = TileFactory.create_app_tile(app_path, app_info)

          if last_inserted_app_element
            dock.apps_array.insert_after(last_inserted_app_element, app_tile)
            last_inserted_app_element = app_tile
          else
            dock.apps_array.add(app_tile)
          end

          messages << "'#{app_name}' added to Dock."

        else
          # Search for app by name
          app_path = AppFinder.find_app_on_disk(item_query)
          unless app_path
            $stderr.puts "Error: App '#{item_query}' not found"
            exit 1
          end

          app_info = PlistReader.read_app_info(app_path)
          unless app_info && app_info['CFBundleIdentifier']
            $stderr.puts "Error: Could not read app info from '#{app_path}'"
            exit 1
          end

          app_name = app_info['CFBundleName'] || app_info['CFBundleDisplayName'] || File.basename(app_path, '.app')

          # Check if app is already in dock
          existing_index, existing_name = dock.find_app(app_info['CFBundleIdentifier'])

          if existing_index
            $stderr.puts "Warning: '#{existing_name}' is already in the Dock, skipping"
            next
          end

          # Create the app tile
          app_tile = TileFactory.create_app_tile(app_path, app_info)

          if last_inserted_app_element
            dock.apps_array.insert_after(last_inserted_app_element, app_tile)
            last_inserted_app_element = app_tile
          else
            dock.apps_array.add(app_tile)
          end

          messages << "'#{app_name}' added to Dock."
        end
      end

      if messages.empty?
        $stderr.puts "No items were added to the Dock"
        exit 1
      end

      dock.save(messages)
    end

    # Remove app/folder subcommand
    def self.remove(args)
      parser = CLI.remove_parser({})
      parser.order!(args)

      if args.empty?
        $stderr.puts parser
        exit 1
      end

      dock = Dock.new
      messages = []

      # Process each argument
      args.each do |item_query|
        found = false

        # Determine if this looks like a path
        is_path = item_query.include?('/')

        # First check persistent-apps
        index, name = dock.find_app(item_query)

        if index
          app_dicts = dock.get_app_dicts
          dock.apps_array.delete(app_dicts[index])
          messages << "'#{name}' removed from Dock."
          found = true
        end

        # If not found in apps, check persistent-others (folders)
        unless found
          index, name = dock.find_folder(item_query, check_url: is_path)

          if index
            folder_dicts = dock.get_folder_dicts
            dock.others_array.delete(folder_dicts[index])
            messages << "'#{name}' removed from Dock."
            found = true
          end
        end

        unless found
          $stderr.puts "Warning: '#{item_query}' not found in Dock, skipping"
        end
      end

      if messages.empty?
        $stderr.puts "No items were removed from the Dock"
        exit 1
      end

      dock.save(messages)
    end

    # Move app subcommand
    def self.move(args)
      # Accept either order: move --after TARGET ITEM or move ITEM --after TARGET
      options = { after: nil }
      parser = CLI.move_parser(options)
      parser.permute!(args)

      # Now, args should contain the non-option arguments (either [item] or [target, item] or [item, target])
      after_target = options[:after]

      # Accept either order: --after TARGET ITEM or ITEM --after TARGET
      item_query = nil
      if after_target && args.length == 1
        item_query = args.first
      elsif after_target && args.length == 2
        # Try to infer which is the item and which is the target
        if args[0].downcase == after_target.downcase
          item_query = args[1]
        elsif args[1].downcase == after_target.downcase
          item_query = args[0]
        else
          # Default: treat first as item
          item_query = args[0]
        end
      else
        $stderr.puts parser
        $stderr.puts "\nError: You must specify an item to move and a target with --after."
        exit 1
      end

      if !after_target || !item_query
        $stderr.puts parser
        $stderr.puts "\nError: You must specify an item to move and a target with --after."
        exit 1
      end

      dock = Dock.new

      # Find the item to move (check apps first, then folders)
      move_array, move_element, move_name = dock.find_item(item_query, check_url: true)

      unless move_element
        $stderr.puts "Error: '#{item_query}' not found in Dock"
        exit 1
      end

      # Find the target (check apps first, then folders)
      after_array, after_element, after_name = dock.find_item(after_target, check_url: true)

      unless after_element
        $stderr.puts "Error: '#{after_target}' not found in Dock"
        exit 1
      end

      # Check if they're the same item
      if move_element == after_element
        $stderr.puts "Error: Cannot move an item after itself"
        exit 1
      end

      # Check if moving between arrays (apps <-> folders) - not allowed
      if move_array != after_array
        $stderr.puts "Error: Cannot move items between apps and folders sections"
        exit 1
      end

      # Remove from current position
      move_array.delete(move_element)

      # Insert after target
      move_array.insert_after(after_element, move_element)

      dock.save("'#{move_name}' moved after '#{after_name}'.")
    end
  end
end

