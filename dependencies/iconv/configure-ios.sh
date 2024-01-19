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

TARGET="iPhoneOS"
SDK_IOS_MIN_VERSION=10.0
DEVELOPER="$(xcode-select --print-path)"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
TARGET_TRIPLE="arm64-apple-ios$SDK_IOS_MIN_VERSION"
HOST_TRIPLE="aarch64-apple-darwin"
MARCH="arm64"

SDK_IOS_VERSION="`xcodebuild -showsdks 2>/dev/null | grep 'sdk iphoneos' | sed 's/.*iphoneos\(.*\)/\1/'`"
SDK_ID="$(echo "$TARGET$SDK_IOS_VERSION" | tr A-Z a-z)"
SYSROOT="$(xcodebuild -version -sdk "$SDK_ID" 2>/dev/null | egrep '^Path: ' | cut -d ' ' -f 2)"

# Configure iconv for iOS
cp -r libiconv $temp_dir/libiconv
pushd $temp_dir/libiconv
	./autogen.sh --host=$TARGET_TRIPLE
	./configure --host=$TARGET_TRIPLE
popd

# Copy public header
cp $temp_dir/libiconv/include/iconv.h ./include

# Copy config headers
cp $temp_dir/libiconv/config.h ./config/ios
cp $temp_dir/libiconv/libcharset/include/localcharset.h ./config/ios
cp $temp_dir/libiconv/lib/translit.h ./config/ios
cp $temp_dir/libiconv/lib/flags.h ./config/ios
cp $temp_dir/libiconv/lib/aliases.h ./config/ios
cp $temp_dir/libiconv/lib/canonical.h ./config/ios
cp $temp_dir/libiconv/lib/canonical_local.h ./config/ios
