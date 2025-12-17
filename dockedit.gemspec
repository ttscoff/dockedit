# frozen_string_literal: true

require_relative 'lib/dockedit/version'

Gem::Specification.new do |spec|
  spec.name          = 'dockedit'
  spec.version       = DockEdit::VERSION
  spec.authors       = ['Brett Terpstra']
  spec.email         = ['github@brettterpstra.com']

  spec.summary       = 'A command-line tool to edit the macOS Dock'
  spec.description   = 'dockedit allows you to add, remove, move, and manage apps and folders in your macOS Dock from the command line'
  spec.homepage      = 'https://github.com/ttscoff/dockedit'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = 'bin'
  spec.executables   = ['dockedit']
  spec.require_paths = ['lib']

  spec.add_dependency 'rexml', '~> 3.2'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ttscoff/dockedit'
  spec.metadata['changelog_uri'] = 'https://github.com/ttscoff/dockedit/blob/main/CHANGELOG.md'
end
