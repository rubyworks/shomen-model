module Shomen

  require 'optparse'
  require 'yaml'
  require 'json'

  # Command line interface. (YARD oriented for now).
  def self.cli(*argv)
    case cmd = argv.shift
    when 'server'
      require 'shomen/server'
    when 'yard'
      require 'shomen/cli/yard'
      CLI::YARDCommand.run(*argv)
    when 'rdoc'
      require 'shomen/cli/rdoc'
      CLI::RDocCommand.run(*argv)
    else
      abort "error: unrecognized command - #{cmd}"
    end
  end

end
