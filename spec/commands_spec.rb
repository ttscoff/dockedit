require 'spec_helper'

RSpec.describe DockEdit::Commands do
  describe '.space' do
    let(:apps_array) { instance_double('AppsArray') }
    let(:dock) { instance_double(DockEdit::Dock, apps_array: apps_array, get_app_dicts: [], find_app: nil, save: nil) }

    before do
      allow(DockEdit::Dock).to receive(:new).and_return(dock)
    end

    it 'adds a full-size spacer at the end when no options are given' do
      spacer = instance_double('SpacerTile')

      expect(DockEdit::TileFactory).to receive(:create_spacer_tile)
        .with(small: false)
        .and_return(spacer)
      expect(apps_array).to receive(:add).with(spacer)
      expect(dock).to receive(:save).with(['Space added to end of Dock.'])

      described_class.space([])
    end

    it 'adds a small spacer after a named app when --small and --after are used' do
      spacer = instance_double('SpacerTile')
      app_dict = instance_double('AppDict')
      app_dicts = [app_dict]

      allow(dock).to receive(:get_app_dicts).and_return(app_dicts)
      allow(dock).to receive(:find_app).with('Safari').and_return([0, 'Safari'])

      expect(DockEdit::TileFactory).to receive(:create_spacer_tile)
        .with(small: true)
        .and_return(spacer)
      expect(apps_array).to receive(:insert_after).with(app_dict, spacer)
      expect(dock).to receive(:save).with(["Small space inserted after 'Safari'."])

      described_class.space(%w[--small --after Safari])
    end
  end

  describe '.add' do
    let(:apps_array) { instance_double('AppsArray', insert_after: nil, add: nil) }
    let(:others_array) { instance_double('OthersArray', insert_after: nil, add: nil) }
    let(:dock) do
      instance_double(
        DockEdit::Dock,
        apps_array: apps_array,
        others_array: others_array,
        find_item: [nil, nil, nil],
        find_folder: [nil, nil],
        find_app: [nil, nil],
        get_folder_dicts: [],
        save: nil
      )
    end

    before do
      allow(DockEdit::Dock).to receive(:new).and_return(dock)
    end

    it 'adds a folder shortcut to the folders section' do
      folder_path = File.expand_path('~/Downloads')

      allow(DockEdit::PathUtils).to receive(:folder_path?).with('downloads').and_return(true)
      allow(DockEdit::PathUtils).to receive(:expand_path_shortcut).with('downloads').and_return(folder_path)
      allow(File).to receive(:directory?).with(folder_path).and_return(true)

      folder_tile = instance_double('FolderTile')
      expect(DockEdit::TileFactory).to receive(:create_folder_tile)
        .with(folder_path, show_as: 4, display_as: 1)
        .and_return(folder_tile)

      expect(others_array).to receive(:add).with(folder_tile)
      expect(dock).to receive(:save).with(["'Downloads' folder added to Dock."])

      described_class.add(['downloads'])
    end

    it 'adds an explicit app path to the apps section' do
      app_path = '/Applications/Foo.app'
      info_plist_path = File.join(app_path, 'Contents', 'Info.plist')

      allow(DockEdit::PathUtils).to receive(:folder_path?).with(app_path).and_return(false)
      allow(DockEdit::PathUtils).to receive(:explicit_app_path?).with(app_path).and_return(true)
      allow(File).to receive(:expand_path).with(app_path).and_return(app_path)
      allow(File).to receive(:exist?).with(info_plist_path).and_return(true)

      app_info = {
        'CFBundleIdentifier' => 'com.example.Foo',
        'CFBundleName' => 'Foo'
      }
      allow(DockEdit::PlistReader).to receive(:read_app_info).with(app_path).and_return(app_info)
      allow(dock).to receive(:find_app).with('com.example.Foo').and_return([nil, nil])

      app_tile = instance_double('AppTile')
      expect(DockEdit::TileFactory).to receive(:create_app_tile)
        .with(app_path, app_info)
        .and_return(app_tile)

      expect(apps_array).to receive(:add).with(app_tile)
      expect(dock).to receive(:save).with(["'Foo' added to Dock."])

      described_class.add([app_path])
    end
  end

  describe '.remove' do
    let(:apps_array) { instance_double('AppsArray') }
    let(:dock) do
      instance_double(
        DockEdit::Dock,
        apps_array: apps_array,
        get_app_dicts: [instance_double('AppDict')],
        find_app: [0, 'Safari'],
        find_folder: [nil, nil],
        get_folder_dicts: [],
        save: nil
      )
    end

    before do
      allow(DockEdit::Dock).to receive(:new).and_return(dock)
    end

    it 'removes an app by name' do
      app_dict = dock.get_app_dicts.first

      expect(apps_array).to receive(:delete).with(app_dict)
      expect(dock).to receive(:save).with(["'Safari' removed from Dock."])

      described_class.remove(['Safari'])
    end
  end

  describe '.move' do
    let(:apps_array) { instance_double('AppsArray') }
    let(:move_element) { instance_double('MoveElement') }
    let(:after_element) { instance_double('AfterElement') }
    let(:dock) do
      instance_double(
        DockEdit::Dock,
        find_item: nil,
        save: nil
      )
    end

    before do
      allow(DockEdit::Dock).to receive(:new).and_return(dock)
    end

    it 'moves an item after another within the same array' do
      allow(dock).to receive(:find_item).with('Safari', check_url: true)
                                        .and_return([apps_array, move_element, 'Safari'])
      allow(dock).to receive(:find_item).with('Terminal', check_url: true)
                                        .and_return([apps_array, after_element, 'Terminal'])

      expect(apps_array).to receive(:delete).with(move_element)
      expect(apps_array).to receive(:insert_after).with(after_element, move_element)
      expect(dock).to receive(:save).with("'Safari' moved after 'Terminal'.")

      described_class.move(%w[--after Terminal Safari])
    end
  end
end


