require 'spec_helper'

RSpec.describe 'Dock and Commands integration on fixture plist' do
  let(:dummy_doc) do
    # Load the current test plist into a REXML::Document
    REXML::Document.new(File.read(DockEdit::Constants::DOCK_PLIST))
  end

  before do
    # Ensure PlistReader/Writer operate on the overridden DOCK_PLIST and do not
    # call external system commands during tests.
    allow(DockEdit::PlistReader).to receive(:load_dock_plist).and_return(dummy_doc)

    allow(DockEdit::PlistWriter).to receive(:write_plist_and_restart) do |doc, messages|
      # Write back to the test plist without calling plutil or killall
      formatter = REXML::Formatters::Pretty.new(2)
      formatter.compact = true

      output = StringIO.new
      output << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
      output << "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
      formatter.write(doc.root, output)
      output << "\n"

      File.write(DockEdit::Constants::DOCK_PLIST, output.string)
      @saved_messages = Array(messages)
      # Do not exit in tests
    end
  end

  it 'initializes Dock with empty arrays from the fixture' do
    dock = DockEdit::Dock.new
    expect(dock.get_app_dicts).to eq([])
    expect(dock.get_folder_dicts).to eq([])
  end
end


