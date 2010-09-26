#!/usr/bin/env ruby

desc "package"
task :package do
  sh %{RUBYOPT="-roll -rubygems" syckle package}
end

desc "install"
task :install => :package do
  sh %{sudo gem install --no-ri pkg/rdoc-shomen-0.1.0.gem}
end

