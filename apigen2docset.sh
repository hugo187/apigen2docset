#!/bin/bash

#
# apigen2docset.sh by Petr Dvorak (https://github.com/hugo187/apigen2docset)
# based on script by Robin Zhong 
#



#
# check for number of parameters
#

if [ $# != 1 ]; then 
	echo ""
	echo "Apigen2docset - Convert ApiGen documentation to Xcode Documentation Set"
	echo ""
	echo "usage: apigen2docset directory"
	echo 'example: "apigen2docset ~/docs/Nette-API" will generate "Nette-API.docset"'
	echo ""
	exit
fi



#
# script variables
#

docsetutil="/Applications/Xcode.app/Contents/Developer/usr/bin/docsetutil"
source_dir=${1%/}
docset_dir="${source_dir##*/}.docset"
html_dir="$docset_dir/Contents/Resources/Documents"
index_html="$source_dir/index.html"
css_file="$html_dir/resources/style.css"
info_plist="$docset_dir/Contents/Info.plist"
nodes_xml="$docset_dir/Contents/Resources/Nodes.xml"
tokens_xml="$docset_dir/Contents/Resources/Tokens.xml"



#
# check if given path is ok
#

if [ ! -f "$source_dir/index.html" ]; then 
	echo "File '$source_dir/index.html' not found."
	exit
fi



#
# create bundle directory structure
#

mkdir -p "$docset_dir/Contents/Resources/Documents/"



#
# create bundle file info.plist
#

cat > "$info_plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>${source_dir##*/}</string>
	<key>CFBundleName</key>
	<string>${source_dir##*/}</string>
	<key>DocSetPlatformFamily</key>
	<string>php</string>
</dict>
</plist>
EOF



#
# create bundle file nodes.xml
#

cat > "$nodes_xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<DocSetNodes version="1.0">
    <TOC>
        <Node type="folder">
            <Name>${source_dir##*/} Documentation</Name>
            <Path>index.html</Path>
        </Node>
    </TOC>
</DocSetNodes>
EOF



#
# copy documentation resource files to documents directory
#

cp -R "$source_dir/resources/" "$html_dir/resources"



#
# remove unnecessary html fragments (left menu) and put modified files to documents directory
#

find "$source_dir"/*.html -print0 | while read -d $'\0' file
do
	awk '/<!DOCTYPE html>/,/<body>/' "$file" > "${html_dir}/${file##*/}"
	awk '/<div id="right">/,/<\/html>/' "$file" >> "${html_dir}/${file##*/}"
done



#
# modify CSS file (hide navigaton and search bar)
#

echo "#left { display: none; } #right { margin-left: 0; } #splitter { display: none; } #search { display: none; }" >> "$css_file"



#
# find tokens
#

awk '/<h3>Classes<\/h3>/,/<\/ul>/' "$index_html" | grep '<li><a href="class-' | sed -e 's/ class="invalid"//' | sed -e 's/^				<li><a href="//' | sed -e 's/">/ /' | sed -e 's/<\/a><\/li>$//' > classes.tmp
awk '/<h3>Interfaces<\/h3>/,/<\/ul>/' "$index_html" | grep '<li><a href="class-' | sed -e 's/ class="invalid"//' | sed -e 's/^				<li><a href="//' | sed -e 's/">/ /' | sed -e 's/<\/a><\/li>$//' > interfaces.tmp
awk '/<h3>Exceptions<\/h3>/,/<\/ul>/' "$index_html" | grep '<li><a href="class-' | sed -e 's/ class="invalid"//' | sed -e 's/^				<li><a href="//' | sed -e 's/">/ /' | sed -e 's/<\/a><\/li>$//' > exceptions.tmp
awk '/<h3>Functions<\/h3>/,/<\/ul>/' "$index_html" | grep '<li><a href="function-' | sed -e 's/ class="invalid"//' | sed -e 's/^				<li><a href="//' | sed -e 's/">/ /' | sed -e 's/<\/a><\/li>$//' > functions.tmp



#
# merge token files to tokens.xml file
#

cat > "$tokens_xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Tokens version="1.0">
EOF
cat classes.tmp | awk '{print "<File path=\""$1"\"><Token><TokenIdentifier>//apple_ref/cpp/cl/"$2"</TokenIdentifier></Token></File>"}' >> "$tokens_xml"
cat interfaces.tmp | awk '{print "<File path=\""$1"\"><Token><TokenIdentifier>//apple_ref/cpp/intf/"$2"</TokenIdentifier></Token></File>"}' >> "$tokens_xml"
cat exceptions.tmp | awk '{print "<File path=\""$1"\"><Token><TokenIdentifier>//apple_ref/cpp/cl/"$2"</TokenIdentifier></Token></File>"}' >> "$tokens_xml"
cat functions.tmp | awk '{print "<File path=\""$1"\"><Token><TokenIdentifier>//apple_ref/cpp/func/"$2"</TokenIdentifier></Token></File>"}' >> "$tokens_xml"
echo "</Tokens>" >> "$tokens_xml"



#
# generate docsets indexes
#

$docsetutil index "$docset_dir"



#
# remove temporary files
#

rm classes.tmp
rm interfaces.tmp
rm exceptions.tmp
rm functions.tmp
rm "$tokens_xml"



#
# compress generated bundle
#

tar --exclude='.DS_Store' -czf "${source_dir##*/}".tgz "$docset_dir"



