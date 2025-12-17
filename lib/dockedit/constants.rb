# frozen_string_literal: true

module DockEdit
  # Constants used across the dockedit implementation.
  module Constants
    # Absolute path to the Dock preferences plist.
    #
    # In tests this constant is overridden to point at a temporary copy.
    DOCK_PLIST = File.expand_path('~/Library/Preferences/com.apple.dock.plist')

    # Mapping of short folder names to full filesystem paths.
    #
    # Keys are regular expressions matched against user input; values are
    # expanded paths.
    PATH_SHORTCUTS = {
      /^desktop$/i => File.expand_path('~/Desktop'),
      /^downloads$/i => File.expand_path('~/Downloads'),
      /^(home|~)$/i => File.expand_path('~'),
      /^library$/i => File.expand_path('~/Library'),
      /^documents$/i => File.expand_path('~/Documents'),
      /^(applications|apps)$/i => '/Applications',
      /^sites$/i => File.expand_path('~/Sites')
    }.freeze

    # Mapping of show-as string aliases to integer values used in the plist.
    #
    # 1 = fan, 2 = grid, 3 = list, 4 = auto.
    SHOW_AS_VALUES = {
      'f' => 1, 'fan' => 1,
      'g' => 2, 'grid' => 2,
      'l' => 3, 'list' => 3,
      'a' => 4, 'auto' => 4
    }.freeze

    # Mapping of display-as string aliases to integer values used in the plist.
    #
    # 0 = stack, 1 = folder.
    DISPLAY_AS_VALUES = {
      's' => 0, 'stack' => 0,
      'f' => 1, 'folder' => 1
    }.freeze
  end
end

