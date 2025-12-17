# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'
require_relative 'lib/dockedit/version'

# Load the gemspec
Gem::Specification.load('dockedit.gemspec')

namespace :version do
  desc 'Bump version: major, minor, or patch'
  task :bump, [:level] do |_t, args|
    level = (args[:level] || 'patch').to_sym
    version_file = 'lib/dockedit/version.rb'

    current_version = DockEdit::VERSION
    parts = current_version.split('.').map(&:to_i)

    case level
    when :major
      parts[0] += 1
      parts[1] = 0
      parts[2] = 0
    when :minor
      parts[1] += 1
      parts[2] = 0
    when :patch
      parts[2] += 1
    else
      raise "Invalid version level: #{level}. Use major, minor, or patch"
    end

    new_version = parts.join('.')

    # Read the version file
    content = File.read(version_file)
    # Replace the version
    content.gsub!(/VERSION = ['"][\d.]+['"]/, "VERSION = '#{new_version}'")

    # Write it back
    File.write(version_file, content)

    puts "Version bumped from #{current_version} to #{new_version}"
    puts "Don't forget to commit and tag:"
    puts "  git add #{version_file}"
    puts "  git commit -m 'Bump version to #{new_version}'"
    puts "  git tag -a v#{new_version} -m 'Version #{new_version}'"
    puts '  git push && git push --tags'
  end

  desc 'Show current version'
  task :show do
    puts DockEdit::VERSION
  end
end

desc 'Remove generated files'
task :clobber do
  require 'fileutils'
  FileUtils.rm_rf('pkg')
  puts 'Removed pkg directory'
end

desc 'Build the gem'
task :build do
  require 'rubygems/package'
  require 'fileutils'

  FileUtils.mkdir_p('pkg')

  sh 'gem build dockedit.gemspec'
  FileUtils.mv("dockedit-#{DockEdit::VERSION}.gem", "pkg/dockedit-#{DockEdit::VERSION}.gem")
  puts "Built gem: pkg/dockedit-#{DockEdit::VERSION}.gem"
end

desc 'Run the test suite (RSpec)'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc 'Generate RDoc documentation'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "dockedit #{DockEdit::VERSION}"
  rdoc.options  = ['--line-numbers', '--inline-source']
  rdoc.rdoc_files.include('README.md', 'lib/**/*.rb')
end

desc 'Package the gem (build and place in pkg/)'
task package: %i[clobber build]

desc 'Install the gem locally'
task :install do
  sh "gem install pkg/dockedit-#{DockEdit::VERSION}.gem"
end
