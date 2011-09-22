== Metadata

All Shomen documents include a `(metadata)` entry which provides information
about a project in general. Shomen pulls the metadata from one of two sources.
First, if there is a `.ruby` file in a project it will use the data as given.
Shomen's metadata format follows the .ruby specification directly. But, if there
is no `.ruby` file in a project, shomen will look for a .gemspec file and
convert it (as much as is possible) to the .ruby spec for inclusion.

=== Using a `.ruby` File

TODO

=== Using a `.gemspec` File

TODO

=== Alternate Formats for Other Languages

Of course, if the Shomen documentation standard is used for non-Ruby projects,
then the metadata specification can vary. While Shomen is designed primarily
with Ruby i8n mind, it is general enough to serve just about any object-oriented
programming language.

