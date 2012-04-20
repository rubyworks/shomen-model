module Shomen

  # Public: Route subcommands to specific commands.
  #
  def self.cli(*argv)
    subcmd = argv.unshift
    exec "shomen-#{subcmd}", *argv
  end

end

