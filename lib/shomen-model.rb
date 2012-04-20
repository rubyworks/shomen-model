# Shomen is an intermediary documentation model designed for documenting
# object-oriented programming languages, particularly Ruby. The specification
# is a flat mapping, without internal referencing, suitable for storage in both
# YAML and JSON formats.
#
module Shomen
end

if RUBY_VERSION > '1.9'
  require_relative 'shomen-model/core_ext'
  require_relative 'shomen-model/generator'
  require_relative 'shomen-model/abstract'
  require_relative 'shomen-model/document'
  require_relative 'shomen-model/script'
  require_relative 'shomen-model/module'
  require_relative 'shomen-model/class'
  require_relative 'shomen-model/method'
  require_relative 'shomen-model/attribute'
# require_relative 'shomen-model/function'
  require_relative 'shomen-model/constant'
  require_relative 'shomen-model/metadata'
else
  require 'shomen-model/core_ext'
  require 'shomen-model/generator'
  require 'shomen-model/abstract'
  require 'shomen-model/document'
  require 'shomen-model/script'
  require 'shomen-model/module'
  require 'shomen-model/class'
  require 'shomen-model/method'
  require 'shomen-model/attribute'
# require 'shomen-model/function'
  require 'shomen-model/constant'
  require 'shomen-model/metadata'
end
