#!/bin/sh

set -ex

current_dir="$(dirname "$0")"
temp_dir="/tmp/libetpan-deps"
cd $current_dir

pushd libiconv
	# We need this pull only for configure
	./gitsub.sh pull
popd

rm -rf $temp_dir
mkdir -p $temp_dir

# Configure iconv for macOS
cp -r libiconv $temp_dir/libiconv
pushd $temp_dir/libiconv
	./autogen.sh
	./configure
popd

# Copy public header
cp $temp_dir/libiconv/include/iconv.h ./include

# Copy config headers
cp $temp_dir/libiconv/config.h ./config/macos
cp $temp_dir/libiconv/libcharset/include/localcharset.h ./config/macos
cp $temp_dir/libiconv/lib/translit.h ./config/macos
cp $temp_dir/libiconv/lib/flags.h ./config/macos
cp $temp_dir/libiconv/lib/aliases.h ./config/macos
cp $temp_dir/libiconv/lib/canonical.h ./config/macos
cp $temp_dir/libiconv/lib/canonical_local.h ./config/macos