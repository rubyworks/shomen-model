require 'shomen/cli/yard'
require 'shomen/cli/rdoc'

module Shomen

  # The command line interface for generating Shomen documentation.
  #
  # Shomen options must come first, followed by an `rdoc` or `yard`
  # command depending on which system you wish to use for parsing.
  # The `rdoc` or `yard` commands are passed to the command shell
  # as given so they support all same options as the normal command
  # invocation, less any options shomen must remove or change for the
  # sake fo generating Shomen documentation.
  #
  # NOTE: Currently Shomen doesn't filter the `rdoc` or `yard` command
  # calls as mush as it should, so some options can cause the
  # documentation to be malformed, or not be produced at all, so 
  # please use the options judiciously.
  #
  # @example
  #   shomen -s rdoc -m README [A-Z]*.* lib
  #   shomen yard --readme README.md lib [A-Z]*.*
  #
  def self.cli(*argv)
    idx = argv.index('rdoc') || argv.index('yard')

    abort "ERROR: must specifiy `rdoc` or `yard`." unless idx

    cmd = argv[idx]
    case cmd
    when 'rdoc'
      shomen_options = argv[0...idx]
      parser_command = argv[idx..-1]
      CLI::RDocCommand.cli(*shomen_options).run(*parser_command)
    when 'yard'
      shomen_options = argv[0...idx]
      parser_command = argv[idx..-1]
      CLI::YARDCommand.cli(*shomen_options).run(*parser_command)
    end
  end

end
