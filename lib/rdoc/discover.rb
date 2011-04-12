begin
  require "rubygems"
rescue LoadError
end

begin
  gem 'rdoc', '~> 3'
  gem 'shomen'
  require 'shomen/rdoc/generator'
rescue Gem::LoadError => error
  puts error
rescue LoadError => error
  puts error
end
