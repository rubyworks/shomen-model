#!/usr/bin/env ruby

profile :cov do
  require 'simplecov'
  SimpleCov.start do
    coverage_dir 'log/coverage'
    add_group "RDoc", "lib/shomen/rdoc.rb"
    add_group "YARD", "lib/shomen/yard.rb"
  end
end

