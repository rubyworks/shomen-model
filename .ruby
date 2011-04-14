--- 
name: shomen
spec_version: 1.0.0
title: Shomen
requires: 
- group: []

  name: rdoc
  version: 3~
- group: 
  - build
  name: syckle
  version: 0+
resources: 
  repo: git://github.com/proutils/shomen.git
  home: http://proutils.github.com/shomen
  work: http://github.com/proutils/shomen
manifest: 
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
version: 0.1.0
description: Shomen defines a standardized documentaiton format for Ruby programs which is used by other systems as a common source for rendering.
summary: Standardized Ruby Documentation Format
authors: 
- Thomas Sawyer <transfire@gmail.com>
created: 2010-07-01
