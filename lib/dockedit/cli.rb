# frozen_string_literal: true

module DockEdit
  # Command-line interface and option parsing
  class CLI
    def self.add_parser(options)
      OptionParser.new do |opts|
        opts.banner = "Usage: dockedit add [options] <app_or_folder> [...]"
        opts.separator ""
        opts.separator "Examples:"
        opts.separator "  dockedit add Safari Terminal"
        opts.separator "  dockedit add ~/Downloads --show grid --display stack"
        opts.separator "  dockedit add --after Safari Notes"
        opts.separator "  dockedit add ~/Sites --display folder --show grid"
        opts.on('-a', '--after ITEM', 'Insert after specified app/folder (fuzzy match)') { |app| options[:after] = app }
        opts.on('--show TYPE', '--view TYPE', 'Folder view: fan/f, grid/g, list/l, auto/a (default: auto)') { |t| options[:show_as] = Parsers.parse_show_as(t) }
        opts.on('--display TYPE', 'Folder style: folder/f, stack/s (default: folder)') { |t| options[:display_as] = Parsers.parse_display_as(t) }
      end
    end

    def self.space_parser(options)
      OptionParser.new do |opts|
        opts.banner = "Usage: dockedit space [options]"
        opts.separator ""
        opts.separator "Examples:"
        opts.separator "  dockedit space"
        opts.separator "  dockedit space --small"
        opts.separator "  dockedit space --after Safari"
        opts.separator "  dockedit space --small --after Terminal --after Safari"
        opts.on('-s', '--small', '--half', 'Insert a small/half-size space') { options[:small] = true }
        opts.on('-a', '--after APP', 'Insert after specified app (fuzzy match, repeatable)') { |app| options[:after] << app }
      end
    end

    def self.move_parser(options)
      OptionParser.new do |opts|
        opts.banner = "Usage: dockedit move --after <target> <item_to_move> OR dockedit move <item_to_move> --after <target>"
        opts.separator ""
        opts.separator "Examples:"
        opts.separator "  dockedit move --after Terminal Safari"
        opts.separator "  dockedit move Safari --after Terminal"
        opts.on('-a', '--after ITEM', 'Move after specified app/folder (required, fuzzy match)') { |app| options[:after] = app }
      end
    end

    def self.remove_parser(_options = {})
      OptionParser.new do |opts|
        opts.banner = "Usage: dockedit remove <app_or_folder> [...]"
        opts.separator ""
        opts.separator "Examples:"
        opts.separator "  dockedit remove Safari Terminal"
        opts.separator "  dockedit remove ~/Downloads"
        opts.separator "  dockedit remove --help"
      end
    end

    def self.main_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: dockedit <subcommand> [options] [args]"
        opts.separator ""
        opts.separator "Subcommands:"
        opts.separator "  add [-a|--after <item>] [--show-as TYPE] <item>...  Add app(s)/folder(s)"
        opts.separator "  move -a|--after <item> <item>                       Move an item after another"
        opts.separator "  remove <item>...                                    Remove app(s)/folder(s)"
        opts.separator "  space [-s|--small] [-a|--after <app>]               Insert space(s)"
        opts.separator "  help [subcommand]                                   Show help for a subcommand"
        opts.separator ""
        opts.separator "Folder shortcuts: desktop, downloads, home, library, documents, applications, sites"
        opts.separator ""
        opts.separator "Examples:"
        opts.separator "  dockedit add Safari Terminal"
        opts.separator "  dockedit add ~/Downloads --show grid --display stack"
        opts.separator "  dockedit add Notes --after Safari"
        opts.separator "  dockedit space --small --after Safari"
        opts.separator "  dockedit move --after Terminal Safari"
        opts.separator "  dockedit move Safari --after Terminal"
        opts.separator "  dockedit help add"
        opts.separator ""
        opts.separator "Options:"
        opts.on('-h', '--help', 'Show this help') do
          puts opts
          exit 0
        end
      end
    end

    # Main entry point
    def self.run
      global_parser = main_parser

      if ARGV.empty?
        puts global_parser
        exit 0
      end

      subcommand = ARGV.shift

      case subcommand
      when '-v', '--version'
        puts DockEdit::VERSION
        exit 0
      when 'add'
        Commands.add(ARGV)
      when 'move'
        Commands.move(ARGV)
      when 'remove'
        Commands.remove(ARGV)
      when 'space'
        Commands.space(ARGV)
      when 'help', '-h', '--help'
        help_target = ARGV.shift
        case help_target
        when nil
          puts main_parser
        when 'add'
          puts add_parser({})
        when 'move'
          puts move_parser({})
        when 'remove'
          puts remove_parser({})
        when 'space'
          puts space_parser({})
        else
          $stderr.puts "Unknown subcommand for help: #{help_target}"
          $stderr.puts "Valid subcommands: add, move, remove, space"
          exit 1
        end
        exit 0
      else
        $stderr.puts "Unknown subcommand: #{subcommand}"
        $stderr.puts "Run 'dockedit --help' for usage"
        exit 1
      end
    end
  end
end

