# frozen_string_literal: true

# dockedit - A script to edit the macOS Dock
# Usage: dockedit <subcommand> [options] [args]

require 'rexml/document'
require 'fileutils'
require 'optparse'
require 'uri'
require 'stringio'

require_relative 'dockedit/version'
require_relative 'dockedit/constants'
require_relative 'dockedit/matcher'
require_relative 'dockedit/path_utils'
require_relative 'dockedit/plist_reader'
require_relative 'dockedit/plist_writer'
require_relative 'dockedit/app_finder'
require_relative 'dockedit/tile_factory'
require_relative 'dockedit/folder_updater'
require_relative 'dockedit/parsers'
require_relative 'dockedit/dock'
require_relative 'dockedit/commands'
require_relative 'dockedit/cli'

