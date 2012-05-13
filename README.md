apigen2docset
=============

Shell script to convert [ApiGen](http://apigen.org/) documentation to [Xcode Documentation Set](https://developer.apple.com/library/mac/#documentation/DeveloperTools/Conceptual/Documentation_Sets/000-Introduction/introduction.html). Main purpose is to make ApiGen documentation available for [Dash](http://kapeli.com/dash/) - snippet manager and documentation browser for OS X.

The script does the following operations:

- Creates docset bundle directory structure.
- Creates required bundle files (info.plist, nodes.xml, etc.).
- Removes unnecessary html fragments (left navigation menu) from documentation files and puts modified files to corresponding bundle subdirectory.
- Modifies documentation CSS file (to hide unnecessary search bar).
- Creates token XML file by searching index.html for class, interface, exception and function names.
- Converts token XML file to documentation index using [docsetutil](http://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/Xcode-3.2.1/man1/docsetutil.1.html).

Requirements
-------------

The script requires [docsetutil](http://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/Xcode-3.2.1/man1/docsetutil.1.html) installed in the following location: `/Applications/Xcode.app/Contents/Developer/usr/bin/docsetutil`. Please adjust [`docsetutil`](https://github.com/hugo187/apigen2docset/blob/master/apigen2docset.sh#L22) variable if you have Xcode tools installed in different location. 

The script can convert documentation generated using __ApiGen 2.6.1__ and __default template__.

Usage
-----

`apigen2docset directory`

You have to specify a directory where ApiGen documentation is located. Directory name is used as name for generated Docset bundle. Files in source directory are not be modified. 

Example
-------

`./apigen2docset.sh ~/docs/Nette-API`

will generate `Nette-API.docset` bundle.

Screenshot
----------

Screenshot of ApiGen documentation viewed using [Dash](http://kapeli.com/dash/) - snippet manager and documentation browser for OS X.

![Sample screenshot](https://github.com/hugo187/apigen2docset/raw/master/readme_resources/screnshot.png)