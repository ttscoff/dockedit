require 'spec_helper'

RSpec.describe DockEdit::CLI do
  def run_with_argv(argv)
    original_argv = ARGV.dup
    ARGV.replace(argv)
    begin
      described_class.run
    rescue SystemExit => e
      e.status
    ensure
      ARGV.replace(original_argv)
    end
  end

  describe 'version flag' do
    it 'prints the version for -v' do
      expect do
        status = run_with_argv(['-v'])
        expect(status).to eq(0)
      end.to output(/#{Regexp.escape(DockEdit::VERSION)}/).to_stdout
    end

    it 'prints the version for --version' do
      expect do
        status = run_with_argv(['--version'])
        expect(status).to eq(0)
      end.to output(/#{Regexp.escape(DockEdit::VERSION)}/).to_stdout
    end
  end

  describe 'help handling' do
    it 'prints main help when no args' do
      expect do
        status = run_with_argv([])
        expect(status).to eq(0)
      end.to output(/Usage: dockedit/).to_stdout
    end
  end
end


