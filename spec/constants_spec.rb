require 'spec_helper'

RSpec.describe DockEdit::Constants do
  describe 'PATH_SHORTCUTS' do
    it 'expands desktop and downloads' do
      desktop = described_class::PATH_SHORTCUTS.keys.find { |re| re =~ 'desktop' }
      downloads = described_class::PATH_SHORTCUTS.keys.find { |re| re =~ 'downloads' }

      expect(described_class::PATH_SHORTCUTS[desktop]).to eq(File.expand_path('~/Desktop'))
      expect(described_class::PATH_SHORTCUTS[downloads]).to eq(File.expand_path('~/Downloads'))
    end

    it 'supports home and ~' do
      home_re = described_class::PATH_SHORTCUTS.keys.find { |re| re =~ 'home' }
      tilde_re = described_class::PATH_SHORTCUTS.keys.find { |re| re =~ '~' }

      expect(described_class::PATH_SHORTCUTS[home_re]).to eq(File.expand_path('~'))
      expect(described_class::PATH_SHORTCUTS[tilde_re]).to eq(File.expand_path('~'))
    end
  end
end


