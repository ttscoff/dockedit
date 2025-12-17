require 'spec_helper'

RSpec.describe DockEdit::Parsers do
  describe '.parse_show_as' do
    it 'parses fan aliases' do
      expect(described_class.parse_show_as('fan')).to eq(1)
      expect(described_class.parse_show_as('F')).to eq(1)
    end

    it 'parses grid aliases' do
      expect(described_class.parse_show_as('grid')).to eq(2)
      expect(described_class.parse_show_as('g')).to eq(2)
    end

    it 'parses list aliases' do
      expect(described_class.parse_show_as('list')).to eq(3)
      expect(described_class.parse_show_as('l')).to eq(3)
    end

    it 'parses auto aliases and defaults unknown to auto' do
      expect(described_class.parse_show_as('auto')).to eq(4)
      expect(described_class.parse_show_as('a')).to eq(4)
      expect(described_class.parse_show_as('unknown')).to eq(4)
    end

    it 'returns nil for nil input' do
      expect(described_class.parse_show_as(nil)).to be_nil
    end
  end

  describe '.show_as_name' do
    it 'returns human-readable names' do
      expect(described_class.show_as_name(1)).to eq('fan')
      expect(described_class.show_as_name(2)).to eq('grid')
      expect(described_class.show_as_name(3)).to eq('list')
      expect(described_class.show_as_name(4)).to eq('auto')
      expect(described_class.show_as_name(999)).to eq('auto')
    end
  end

  describe '.parse_display_as' do
    it 'parses stack aliases' do
      expect(described_class.parse_display_as('stack')).to eq(0)
      expect(described_class.parse_display_as('s')).to eq(0)
    end

    it 'parses folder aliases' do
      expect(described_class.parse_display_as('folder')).to eq(1)
      expect(described_class.parse_display_as('f')).to eq(1)
    end

    it 'returns nil for unknown or nil' do
      expect(described_class.parse_display_as('bogus')).to be_nil
      expect(described_class.parse_display_as(nil)).to be_nil
    end
  end

  describe '.display_as_name' do
    it 'returns human-readable names' do
      expect(described_class.display_as_name(0)).to eq('stack')
      expect(described_class.display_as_name(1)).to eq('folder')
      expect(described_class.display_as_name(999)).to eq('stack')
    end
  end
end


