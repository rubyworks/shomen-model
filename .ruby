---
source:
- var
authors:
- name: trans
  email: transfire@gmail.com
copyrights: []
requirements:
- name: rdoc
  version: 3+
- name: yard
- name: rack
- name: detroit
  groups:
  - build
  development: true
- name: reap
  groups:
  - build
  development: true
dependencies: []
alternatives: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/shomen.git
  scm: git
  name: upstream
resources:
  home: http://rubyworks.github.com/shomen
  docs: http://github.com/rubyworks/shomen/wiki
  code: http://github.com/rubyworks/shomen
  bugs: http://github.com/rubyworks/shomen/issues
  mail: http://groups.google.com/groups/rubyworks-mailinglist
extra: {}
load_path:
- lib
revision: 0
created: '2010-07-01'
summary: Standardized Object-Oriented Documentation Model
title: Shomen
version: 0.1.2
name: shomen
description: ! "Shomen defines a standard API documentaiton format for object-oriented
  software\n(Ruby programs in particular) which can be used by documentation interfaces,
  \ne.g. Hypervisor, to render API documentation."
organization: rubyworks
date: '2012-03-06'
