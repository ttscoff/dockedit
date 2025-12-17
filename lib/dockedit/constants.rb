# frozen_string_literal: true

module DockEdit
  module Constants
    DOCK_PLIST = File.expand_path('~/Library/Preferences/com.apple.dock.plist')

    # Path shortcuts for folders
    PATH_SHORTCUTS = {
      /^desktop$/i => File.expand_path('~/Desktop'),
      /^downloads$/i => File.expand_path('~/Downloads'),
      /^(home|~)$/i => File.expand_path('~'),
      /^library$/i => File.expand_path('~/Library'),
      /^documents$/i => File.expand_path('~/Documents'),
      /^(applications|apps)$/i => '/Applications',
      /^sites$/i => File.expand_path('~/Sites')
    }.freeze

    # Show-as values for folder display
    SHOW_AS_VALUES = {
      'f' => 1, 'fan' => 1,
      'g' => 2, 'grid' => 2,
      'l' => 3, 'list' => 3,
      'a' => 4, 'auto' => 4
    }.freeze

    # Display-as values for folder appearance
    DISPLAY_AS_VALUES = {
      's' => 0, 'stack' => 0,
      'f' => 1, 'folder' => 1
    }.freeze
  end
end

