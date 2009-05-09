#!/bin/bash
#
# package.sh -- functions to generate a package page
#
# Copyright © 2008 Lionel Le Folgoc <mrpouit@ubuntu.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

function medibuntu_resources {
	echo "<h3>Medibuntu resources:</h3>" >> $out
	echo "<ul>" >> $out
	# Bug report
	echo "<li><a href=\"https://bugs.launchpad.net/medibuntu/+bugs\">Bug reports</a></li>" >> $out
	# Changelog
	echo "<li><a href=\"$CHANGELOGS_BASE_URL/$dir/current.$dist/changelog\">Changelog</a></li>" >> $out
	# License file
	echo "<li><a href=\"$CHANGELOGS_BASE_URL/$dir/current.$dist/copyright\">License file</a></li>" >> $out
	echo "</ul>" >> $out
}

function external_resources {
	homepage=$(grep-dctrl -s Homepage -X -F Package $pkg Packages-$ar | awk '{print $2}')
	# If the Homepage field is empty, do not display
	if [ -n "$homepage" ]; then
		echo "<h3>External resources:</h3>" >> $out
		echo "<ul>" >> $out
		echo "<li><a href=\"$homepage\">Homepage</a></li>" >> $out
		echo "</ul>" >> $out
	fi
}

function source_package {
	dscfile=$(grep-dctrl -s Files -X -F Package $src Sources-$comp | tail -n+2 | awk '{print $3}' | grep "\.dsc$")
	difffile=$(grep-dctrl -s Files -X -F Package $src Sources-$comp | tail -n+2 | awk '{print $3}' |grep "\.diff\.gz$")
	tarfile=$(grep-dctrl -s Files -X -F Package $src Sources-$comp | tail -n+2 | awk '{print $3}' | grep "\.tar\.gz$")
	# Some packages (ibm-j2re*) don't have any source package, so do not display for them
	if [ -n "$dscfile" ]; then
		echo "<h3>Source package ($src):</h3>" >> $out
		echo "<ul>" >> $out
		echo "<li><a href=\"$BASE_URL/$dir/$dscfile\">$dscfile</a></li>" >> $out
		# Handle native packages (no diff.gz)
		test -n "$difffile" && echo "<li><a href=\"$BASE_URL/$dir/$difffile\">$difffile</a></li>" >> $out
		echo "<li><a href=\"$BASE_URL/$dir/$tarfile\">$tarfile</a></li>" >> $out
		echo "</ul>" >> $out
	fi
}

function display_links {
	echo "<div id=\"links\">" >> $out
	echo "<div id=\"links_title\">Links for $pkg</div>" >> $out
	medibuntu_resources
	external_resources
	source_package
	echo "</div>" >> $out
}

function short_desc {
	echo "<h2>" >> $out
	grep-dctrl -s Description -X -F Package $pkg Packages-$ar | head -1 | sed 's/^Description: //' >> $out
	echo "</h2>" >> $out
}

function long_desc {
	echo "<div id=\"long_desc\">" >> $out
	# Everybody stand back. I don't know regular expressions.
	grep-dctrl -s Description -X -F Package $pkg Packages-$ar | tail -n+2 | sed 's/^ //' | sed 's/[ 	]*$//' | sed 's/^\./<p><\/p>/' | perl -pe 's/(((\A|\n) [^\n]*)+)/<pre>$1<\/pre>/sgo' >> $out
	echo "</div>" >> $out
}

function depends {
	deps=$(grep-dctrl -s Depends -X -F Package $pkg Packages-$ar | sed 's/^Depends:\ //')
	# Some arch: all packages may not depend on anything
	if [ -n "$deps" ]; then
		echo "<h2>Dependencies</h2>" >> $out
		echo "<div id=\"depends\"><ul><li><span class=\"code\">" >> $out
		echo $deps | sed 's/|/<\/span><\/li><li class=\"alt_deps\"><em>or<\/em><\/li><li><span class=\"code\">/g' | sed 's/,\ /<\/span><\/li><li><span class=\"code\">/g' >> $out
		echo "</span></li></ul></div>" >> $out
	fi
}

function downloads_header {
	echo "<h2>Download $pkg</h2>" >> $out
	echo "<div id=\"download\">" >> $out
	echo "<table>" >> $out
	echo "<tr>" >> $out
	echo "<th>Architecture</th>" >> $out
	echo "<th>Version</th>" >> $out
	echo "<th>Package size</th>" >> $out
	echo "<th>Installed Size</th>" >> $out
	echo "<th>MD5Sum</th>" >> $out
	echo "</tr>" >> $out
}

function download_link {
	echo "<tr>" >> $out
	# Link to the deb file
	filename=$(grep-dctrl -s Filename -X -F Package $pkg Packages-$ar | awk '{print $2}')
	echo "<th><a href=\"$BASE_URL/$filename\">$ar</a></th>"  >> $out
	# Package version (can be different, for example when an arch builder is late)
	echo "<td>$(grep-dctrl -s Version -X -F Package $pkg Packages-$ar | awk '{print $2}')</td>" >> $out
	# Package size
	echo "<td>$(grep-dctrl -s Size -X -F Package $pkg Packages-$ar | awk '{print $2}') B</td>" >> $out
	# Installed size
	echo "<td>$(grep-dctrl -s Installed-Size -X -F Package $pkg Packages-$ar | awk '{print $2}') kB</td>" >> $out
	# MD5Sum (if people want to check)
	echo "<td>$(grep-dctrl -s MD5Sum -X -F Package $pkg Packages-$ar | awk '{print $2}')</td>" >> $out
	echo "</tr>" >> $out
}

function build_package_page {
	if [ $# -ne 7 ]; then
		echo 'Creates the page for the given package.'
		echo 'Usage: build_package_page $package $arch $release $component $section $srcname $dirname'
		exit 1
	fi
	pkg=$1
	ar=$2
	dist=$3
	comp=$4
	sect=$5
	src=$6
	dir=$7
	out="$pkg.html"
	# Write the header
	cat ../../resources/package_header.html > $out
	sed -i "s:@PACKAGE@:$pkg:g" $out
	sed -i "s:@RELEASE@:$dist:g" $out
	sed -i "s:@SECTION@:$sect:g" $out
	# Then call all functions above
	display_links
	short_desc
	long_desc
	depends
	downloads_header
	download_link
	# Do not write the footer now, so downloads for other architectures ca be added
}

function append_arch_download {
	if [ $# -ne 2 ]; then
		echo 'Appends a download link to an existing package page.'
		echo 'Usage: append_arch_download $package $arch'
		exit 1
	fi
	pkg=$1
	ar=$2
	out="$pkg.html"
	download_link
	# Do not write the footer now, so downloads for other architectures ca be added
}
