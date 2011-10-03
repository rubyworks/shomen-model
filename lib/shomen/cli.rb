module Shomen

  # Command line interface. (YARD oriented for now).
  def self.cli(*argv)
    case cmd = argv.shift
    when 'server'
      require 'shomen/server'
    when 'tomdoc'
      require 'shomen/cli/tomdoc'
      CLI::TomDocCommand.run(*argv)
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
