---
source:
- meta
authors:
- name: trans
  email: transfire@gmail.com
copyrights: []
requirements:
- name: qed
  groups:
  - test
  development: true
- name: ae
  groups:
  - test
  development: true
- name: detroit
  groups:
  - build
  development: true
- name: fire
  groups:
  - build
  development: true
dependencies: []
alternatives: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/shomen-model.git
  scm: git
  name: upstream
resources:
- uri: http://rubyworks.github.com/shomen-model
  name: home
  type: home
- uri: http://rubydoc.info/gems/shomen-model/frames
  name: docs
  type: doc
- uri: http://github.com/rubyworks/shomen-model
  name: code
  type: code
- uri: http://github.com/rubyworks/shomen-model/issues
  name: bugs
  type: bugs
- uri: http://groups.google.com/groups/rubyworks-mailinglist
  name: mail
  type: mail
- uri: http://chat.us.freenode.net/rubyworks
  name: chat
  type: chat
extra: {}
load_path:
- lib
revision: 0
created: '2010-07-01'
summary: Ruby Models for Shomen Documentation Format
title: Shomen Model
version: 0.1.0
name: shomen-model
description: ! "Shomen defines a standard API documentaiton format for object-oriented
  software\n(Ruby programs in particular) which can be used by documentation interfaces,
  \ne.g. Hypervisor, to render API documentation. Shomen Model is a set of Ruby\nclasses
  the module this format, and can be used to generate Shomen documentation."
organization: rubyworks
date: '2012-04-20'
