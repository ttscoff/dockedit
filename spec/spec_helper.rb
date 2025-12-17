require 'rspec'
require 'fileutils'
require 'tmpdir'

require_relative '../lib/dockedit'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Ensure specs do not touch the real Dock plist
  config.before(:each) do
    fixtures_dir = File.expand_path('../spec/fixtures', __dir__)
    FileUtils.mkdir_p(fixtures_dir)

    # Use a dummy plist as the source; create a minimal one if it doesn't exist
    dummy_plist = File.join(fixtures_dir, 'dock.plist')
    unless File.exist?(dummy_plist)
      File.write(dummy_plist, <<~PLIST)
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>persistent-apps</key>
          <array/>
          <key>persistent-others</key>
          <array/>
        </dict>
        </plist>
      PLIST
    end

    # Each example works on its own copy of the plist
    test_plist = File.join(Dir.mktmpdir('dockedit_spec'), 'com.apple.dock.plist')
    FileUtils.cp(dummy_plist, test_plist)

    # Point Constants::DOCK_PLIST to the test copy
    DockEdit::Constants.send(:remove_const, :DOCK_PLIST)
    DockEdit::Constants.const_set(:DOCK_PLIST, test_plist)
  end
end


