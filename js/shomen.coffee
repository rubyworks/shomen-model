# Create a shared library for working with shomen doc.json.

class Shomen
  constructor: (docs) ->
    @docs = normalize(docs)

  #
  # Normalize the shomen json. This does a number of things to ensure
  # the data is easy to wrok with:
  #
  # 1. Add index key property to each doc entry.
  # 2. Add html compliant id property to each doc entry.
  # 3.
  #
  normalize: (docs) ->
    for key, doc of docs
      doc.key = key
      if doc.path
        doc.id = make_id('api-' + doc['!'] + '-' + doc.path)  # what not just use key?
      else
        doc.id = 'metadata'
    return docs

  #
  #
  #
  metadata: ->
    @docs['(metadata)']

  #
  # Divy documetation up into categories.
  #
  catagorize: ->
    categories =
      documents: []
      scripts: []
      classes: []
      modules: []
      constants: []
      methods: []

    for key, doc of @doc
      switch doc['!']
        when 'method'
          categories['methods'].push(doc)
        when 'class'
          categories['classes'].push(doc)
        when 'module'
          categories['modules'].push(doc)
        when 'document'
          categories['documents'].push(doc)
        when 'script'
          categories['scripts'].push(doc)
        when 'constant'
          categories['constants'].push(doc)

    categories['methods'].sort = categories['methods'].sort (a,b) -> 
      a.name > b.name ? 1 : -1

    categories['classes'].sort = categories['classes'].sort (a,b) ->
      a.name > b.name ? 1 : -1

    return categories

  #
  # Categorize methods into a two-depth mapping of scope and visibility.
  #
  categorize_methods: (methods) ->
    s = 'instance'
    v = 'public'

    list =
      class:
        public: []
        protected: []
        private: []
      instance: 
        public: []
        protected: []
        private: []

    for doc in methods
      if doc.singleton #declarations.contains('class')
        s = 'class'
      else
        s = 'instance'

      if doc.declarations.contains('private')
        v = 'private'
      else
        if doc.declarations.contains('protected')
          v = 'protected'
        else
          v = 'public'

      list[s][v].push(doc)

    return list

  #
  # Determine primary "readme" document. This function first attempts
  # to find the document specified by the metadata.readme property.
  # If this document does not exist it will search for a document with
  # a name matching /^README/.
  #
  readme: ->
    readme = metadata['readme']
    unless readme
      for d of documentation['documents']
        if d.name.match(/^README/i)
          readme = d
          break
    return readme

  #
  # Create a valid html id from documentation key.
  #
  # @todo Rename this function.
  #
  # @todo Is there not a better way to create a valid html id ?
  #
  make_id: (key) ->
    # key = encodeURIComponent(key);  DID NOT WORK
    key = key.replace(/\</g,  "-l-")
    key = key.replace(/\>/g,  "-g-")
    key = key.replace(/\=/g,  "-e-")
    key = key.replace(/\?/g,  "-q-")
    key = key.replace(/\!/g,  "-x-")
    key = key.replace(/\~/g,  "-t-")
    key = key.replace(/\[/g,  "-b-")
    key = key.replace(/\]/g,  "-k-")
    key = key.replace(/\#/g,  "-h-")
    key = key.replace(/\./g,  "-d-")
    key = key.replace(/\:\:/g,"-C-")
    key = key.replace(/\:/g,  "-c-")
    key = key.replace(/[/]/g, "-s-")
    key = key.replace(/\W+/g, "-")  # TOO GENERAL?
    key = key.replace(/\W+/g, "-")  # For GOOD MEASURE
    key

  #
  # Helper method to parse parameters for request URL.
  #
  getUrlVars: ->
    vars   = []
    index  = window.location.href.indexOf('?') + 1
    hashes = window.location.href.slice(index).split('&')
    for hash in hashes
      h = hash.split('=')
      vars.push(h[0])
      vars[h[0]] = h[1]
    return vars

