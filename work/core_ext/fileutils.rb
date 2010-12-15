require 'fileutils'

#
# TODO: options = { :verbose => $DEBUG_RDOC, :noop => $dryrun }

def fileutils
  $dryrun ? FileUtils::DryRun : FileUtils
end

