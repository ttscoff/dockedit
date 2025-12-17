# frozen_string_literal: true

module DockEdit
  # Handles fuzzy matching for app names and dock items
  class Matcher
    # Calculate match score (lower is better, nil means no match)
    def self.match_score(query, target)
      return nil if target.nil? || target.empty?

      query = query.downcase
      target = target.downcase

      # Exact match - best score
      return 0 if target == query

      # Starts with query
      return 1 if target.start_with?(query)

      # Contains match - score based on position
      if target.include?(query)
        return 2 + target.index(query)
      end

      # Abbreviation match (e.g., "vscode" matches "Visual Studio Code")
      query_chars = query.chars
      target_pos = 0
      matched = true

      query_chars.each do |char|
        found = false
        while target_pos < target.length
          if target[target_pos] == char
            found = true
            target_pos += 1
            break
          end
          target_pos += 1
        end
        unless found
          matched = false
          break
        end
      end

      return 100 + target.length if matched

      nil
    end

    # Fuzzy matching for app names
    def self.fuzzy_match?(query, target)
      !match_score(query, target).nil?
    end

    # Find item index in a dock array (persistent-apps or persistent-others)
    # For folders, also checks file-data._CFURLString
    def self.find_item_index(items_array, query, check_url: false)
      best_score = nil
      best_name = nil
      best_index = nil

      items_array.each_with_index do |item_dict, index|
        next unless item_dict.is_a?(REXML::Element) && item_dict.name == 'dict'

        tile_data = PlistReader.get_tile_data(item_dict)
        next unless tile_data

        file_label = PlistReader.get_tile_value(tile_data, 'file-label')
        bundle_id = PlistReader.get_tile_value(tile_data, 'bundle-identifier')

        scores = []
        scores << match_score(query, file_label)
        scores << match_score(query, bundle_id)

        # For folders, also check URL path
        if check_url
          url_string = PlistReader.get_file_data_url(tile_data)
          if url_string
            # Extract path from file:// URL and decode
            path = URI.decode_www_form_component(url_string.sub(%r{^file://}, '').chomp('/'))
            basename = File.basename(path)
            scores << match_score(query, path)
            scores << match_score(query, basename)
          end
        end

        current_score = scores.compact.min
        next unless current_score

        name = file_label || bundle_id || 'Unknown'
        name_length = name.length

        if best_score.nil? || current_score < best_score ||
           (current_score == best_score && name_length < (best_name&.length || 999))
          best_score = current_score
          best_name = name
          best_index = index
        end
      end

      [best_index, best_name]
    end

    # Alias for backward compatibility
    def self.find_app_index(apps_array, query)
      find_item_index(apps_array, query, check_url: false)
    end
  end
end

