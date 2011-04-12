--- !ruby/object:Gem::Specification 
name: shomen
version: !ruby/object:Gem::Version 
  hash: 27
  prerelease: false
  segments: 
  - 0
  - 1
  - 0
  version: 0.1.0
platform: ruby
authors: 
- Thomas Sawyer <transfire@gmail.com>
autorequire: 
bindir: bin
cert_chain: []

date: 2011-04-12 00:00:00 -04:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: rdoc
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ~>
      - !ruby/object:Gem::Version 
        hash: 5
        segments: 
        - 3
        version: "3"
  type: :runtime
  version_requirements: *id001
- !ruby/object:Gem::Dependency 
  name: syckle
  prerelease: false
  requirement: &id002 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 3
        segments: 
        - 0
        version: "0"
  type: :development
  version_requirements: *id002
description: Shomen defines a standardized documentaiton format for Ruby programs which is used by other systems as a common source for rendering.
email: ""
executables: []

extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- lib/rdoc/discover.rb
- lib/shomen/hyper/index.html
- lib/shomen/hyper/jquery.jqote2.min.js
- lib/shomen/hyper/jquery.js
- lib/shomen/hyper/rdoc.json
- lib/shomen/rdoc/generator.rb
- lib/shomen.yml
- Rakefile
- HISTORY.rdoc
- Profile
- README.rdoc
- NOTES.rdoc
- Syckfile
- Version
has_rdoc: true
homepage: http://proutils.github.com/shomen
licenses: []

post_install_message: 
rdoc_options: 
- --title
- Shomen API
- --main
- README.rdoc
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
requirements: []

rubyforge_project: shomen
rubygems_version: 1.3.7
signing_key: 
specification_version: 3
summary: Standardized Ruby Documentation Format
test_files: []

