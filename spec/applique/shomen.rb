require 'shomen/cli'
require 'stringio'

parser = ENV['parser'] || 'rdoc'

#Before :all do
  if not File.exist?('.ruby')
    dotruby = "---\nname: example\n"
    File.open('.ruby', 'w'){ |f| f << dotruby }
  end
#end

When 'Given a file +(((.*?)))+' do |file, text|
  @file = file
  FileUtils.mkdir_p(File.dirname(file))
  File.open(file, 'w'){ |f| f << text }
end

When 'Running the script through shomen' do
  output = ''
  $stdout = StringIO.new(output,'w+')
  Shomen.cli(parser, '--format', 'yaml', @file)
  $stdout.close
  @shomen = YAML.load(output)
end

