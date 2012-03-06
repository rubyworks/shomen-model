# Shomen

[Website](http://rubyworks.github.com/shomen) /
[User Manual](http://github.com/rubyworks/shomen/wiki) /
[Development](http://github.com/rubyworks/shomen) /
[Mailing List](http://groups.google.com/groups/rubyworks-mailinglist) /
[IRC Channel](http://chat.us.freenode.net/rubyworks)


## Description

Shomen is an intermediary documentation model designed for documenting
object-oriented programming languages, particularly Ruby. The specification
is a flat mapping, without internal referencing, suitable for storage in both
YAML and JSON formats.


## Why?

By using a standard intermediary format, documentation parsers need only concern
themselves with a single output target. And documentation templates in turn only
need to concern themselves with a single input format regardless of the parsing
system that was used to generate it.


## Features

* Update a single portable file to update documentation.
* Site disc footprint is extra small thanks to CDNs.
* Personalize site design to best fit your project.
* Test drive others customizations with your own remote docs!


## Learn

To learn more about Shomen please visit:

* http://rubyworks.github.com/shomen
* http://github.com/rubyworks/shomen/wiki


## Usage

Shomen currently supports parsing via RDoc and YARD. Specify the parser to
use to the shomen command, e.g.

    $ shomen rdoc lib [A-Z]*.* -m README.rdoc > site/doc.json

If a `.document` file exists, of course, the file globs can be omitted.
For yard it's basically the same deal.

    $ shomen yard lib [A-Z]*.* -r README.rdoc > site/doc.json

YARD will use `.yardopts` if it is present, so you generally do not need to
to specify any parameters, e.g.

    $ shomen yard > site/doc.json

Now that you have a Shomen documentation file for you project, you simply need 
to pair it up with a viewer. Currently that means using one of the following

* [HyperVisor](http://github.com/rubyworks/hypervisor)
* [Rebecca](http://github.com/rubyworks/rebecca)
* [Rubyfaux](http://github.com/rubyworks/rubyfaux)

You can copy any of those repos to your website (e.g. site/) and run with it.
If you want to try it out locally, we recommend using [thin](http://code.macournoyer.com/thin/)
to view the site.

    $ cd site
    $ thin start -A file

If you can't use thin, Shomen provides a simplistic rack-based static server
which can be used.

    $ cd site
    $ shomen-server

Viewers don't necessarily need to be copied. All three above can take
a `doc={url-to-shomen-json-file}` http parameter and server up the docs remotely.
You just need to publish your `doc.json` file to a publicly accessible URL.
Note, I recommend that in this case you name the file more specifically,
e.g. `myapp-1.0.0.json`.

See the viewer projects for more information.


## Copying

Copyright (c) 2010 Thomas Sawyer

Shomen is distributed under the terms of the *BSD-2-Clause* license.

See License.txt for license details.
