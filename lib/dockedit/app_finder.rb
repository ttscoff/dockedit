# frozen_string_literal: true

module DockEdit
  # Handles finding applications on disk
  class AppFinder
    # Find app on disk using mdfind
    def self.find_app_on_disk(query)
      # Search in /Applications and /System/Applications
      result = `mdfind -onlyin /Applications -onlyin /System/Applications 'kMDItemKind == "Application" && kMDItemDisplayName == "*#{query}*"cd' 2>/dev/null`.strip

      if result.empty?
        # Fallback to filename search
        result = `mdfind -onlyin /Applications -onlyin /System/Applications 'kMDItemFSName == "*#{query}*.app"cd' 2>/dev/null`.strip
      end

      return nil if result.empty?

      apps = result.split("\n").select { |p| p.end_with?('.app') }
      return nil if apps.empty?

      # Score and sort by best match (shortest name wins on equal score)
      scored = apps.map do |path|
        name = File.basename(path, '.app')
        score = Matcher.match_score(query, name)
        [path, name, score || 999, name.length]
      end

      # Sort by score, then by name length
      scored.sort_by! { |_, _, score, len| [score, len] }

      scored.first&.first
    end
  end
end

