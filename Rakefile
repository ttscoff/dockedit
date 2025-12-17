# frozen_string_literal: true

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

# Override the release task from bundler/gem_tasks
# This version only bumps version, commits, tags, and pushes to GitHub
# The GitHub workflow handles building and pushing to RubyGems
desc 'Bump version, commit changes, tag, and push to GitHub'
task :release, [:level] do |_t, args|
  level = (args[:level] || 'patch').to_sym
  version_file = 'lib/dockedit/version.rb'

  # Validate level
  raise "Invalid version level: #{level}. Use major, minor, or patch" unless %i[major minor patch].include?(level)

  # Get current version
  current_version = DockEdit::VERSION
  parts = current_version.split('.').map(&:to_i)

  # Calculate new version
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
  end

  new_version = parts.join('.')

  # Bump version in file
  content = File.read(version_file)
  content.gsub!(/VERSION = ['"][\d.]+['"]/, "VERSION = '#{new_version}'")
  File.write(version_file, content)

  puts "Version bumped from #{current_version} to #{new_version}"

  # Update CHANGELOG.md first
  puts 'Updating CHANGELOG.md...'
  raise "Failed to update CHANGELOG.md with 'changelog -u'" unless system('changelog -u')

  # Generate changelog commit message
  puts 'Generating commit message from changelog...'

  # Run changelog command to get commit message
  changelog_output = `changelog 2>&1`
  changelog_success = $?.success?

  # Use changelog output, with fallback if it fails or produces no output
  commit_message = if changelog_success && !changelog_output.strip.empty?
                     changelog_output
                   else
                     # Fallback if changelog fails or produces no output
                     "Bump version to #{new_version}"
                   end

  # Save commit message to a file for use with both commit and tag
  require 'tempfile'
  message_file = Tempfile.new('release_msg')
  message_file.write(commit_message)
  message_file.close
  message_path = message_file.path

  begin
    # Ensure we're on a clean branch (or at least warn about uncommitted changes)
    status = `git status --porcelain`.strip
    unless status.empty?
      puts 'Warning: You have uncommitted changes:'
      puts status
    end

    # Stage all changes (including version.rb and CHANGELOG.md)
    sh 'git add -A'

    # Commit with changelog message using the saved file
    sh "git commit -F #{message_path}"

    raise 'Failed to commit changes' unless $?.success?

    puts 'Committed changes with message:'
    puts commit_message.split("\n").first

    # Create tag with the same message
    tag_name = "v#{new_version}"
    sh "git tag -a #{tag_name} -F #{message_path}"
  ensure
    # Clean up the temp file
    message_file.unlink
  end

  # Push to GitHub
  puts 'Pushing to GitHub...'
  sh 'git push'
  sh 'git push --tags'

  puts "\nRelease #{tag_name} pushed to GitHub!"
  puts 'GitHub Actions will build the gem and publish to RubyGems automatically.'
end
