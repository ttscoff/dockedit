# frozen_string_literal: true

module DockEdit
  # Handles fuzzy matching for application names and Dock items.
  #
  # Matching is based on a simple scoring system that prefers exact matches,
  # then "starts with", then substring and abbreviation matches.
  class Matcher
    # Calculate a fuzzy match score between two strings.
    #
    # A lower score means a better match. +nil+ indicates no match at all.
    #
    # @param query [String] User-entered search text.
    # @param target [String] Candidate string to score against.
    # @return [Integer, nil] Score where 0 is best, or +nil+ when there is no match.
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

    # Check whether +target+ fuzzily matches +query+.
    #
    # @param query [String]
    # @param target [String]
    # @return [Boolean] +true+ if {#match_score} returns a non-nil score.
    def self.fuzzy_match?(query, target)
      !match_score(query, target).nil?
    end

    # Find the best-matching item index in a Dock array.
    #
    # This scans a list of Dock tile `<dict>` elements and finds the index
    # whose label, bundle identifier, or (optionally) URL path best matches
    # +query+.
    #
    # @param items_array [Array<REXML::Element>] Array of tile `<dict>` elements.
    # @param query [String] Search term (app name, bundle id, or path fragment).
    # @param check_url [Boolean] Whether to also consider the folder URL path.
    # @return [Array<(Integer, String)>] A pair of `[index, display_name]`, where
    #   +index+ is the best entry index or +nil+ when nothing matches.
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

    # Backwards-compatible alias for finding app indices.
    #
    # @param apps_array [Array<REXML::Element>] App tile `<dict>` elements.
    # @param query [String] Search term.
    # @return [Array<(Integer, String)>] See {#find_item_index}.
    def self.find_app_index(apps_array, query)
      find_item_index(apps_array, query, check_url: false)
    end
  end
end

