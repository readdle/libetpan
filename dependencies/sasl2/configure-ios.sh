#!/bin/sh

set -ex

current_dir="$(dirname "$0")"
temp_dir="/tmp/libetpan-deps"
cd $current_dir

rm -rf $temp_dir
mkdir -p $temp_dir

TARGET="iPhoneOS"
SDK_IOS_MIN_VERSION=10.0
DEVELOPER="$(xcode-select --print-path)"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)

export CROSS_TOP="${SDK%%/SDKs/*}"
export CROSS_SDK="${SDK##*/SDKs/}"
if [ -z "$CROSS_TOP" -o -z "$CROSS_SDK" ]; then
	echo "Failed to parse SDK path '${SDK}'!" >&1
	exit 2
fi

# Copy public headers from cyrus-sasl and data-types (md5)
pushd cyrus-sasl
	public_headers="sasl.h saslplug.h saslutil.h prop.h"
	pushd include
		cp -r $public_headers ../../include/sasl
	popd
	cp ../../../src/data-types/md5global.h ../include/sasl
	cp ../../../src/data-types/md5namespace.h ../include/sasl
popd

cp -r cyrus-sasl $temp_dir/cyrus-sasl
pushd $temp_dir
	# Build OpenSSL with Shared library
	# Unforunetly SASL configure works only with shared library
	mkdir -p $temp_dir/openssl
	mkdir -p $temp_dir/openssl-install
	OPENSSL_VERSION=1.1.1v
	DOWNLOAD_URL_OPENSSL=https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
	wget $DOWNLOAD_URL_OPENSSL -O openssl.tar.gz
	tar -xvf openssl.tar.gz -C openssl --strip-components=1
   	pushd openssl
    	./Configure ios64-cross --prefix=$temp_dir/openssl-install
    	make && make install_sw
    popd

    TARGET_TRIPLE="arm64-apple-ios$SDK_IOS_MIN_VERSION"
	HOST_TRIPLE="aarch64-apple-darwin"
	MARCH="arm64"

	SDK_IOS_VERSION="`xcodebuild -showsdks 2>/dev/null | grep 'sdk iphoneos' | sed 's/.*iphoneos\(.*\)/\1/'`"
	SDK_ID="$(echo "$TARGET$SDK_IOS_VERSION" | tr A-Z a-z)"
	SYSROOT="$(xcodebuild -version -sdk "$SDK_ID" 2>/dev/null | egrep '^Path: ' | cut -d ' ' -f 2)"

	pushd cyrus-sasl
		./autogen.sh --host=$TARGET_TRIPLE \
			--with-openssl=$temp_dir/openssl-install \
			--enable-login \
			--enable-ntlm \
			--enable-gssapi=no \
			--with-dblib=none \
			--enable-static
	popd
popd

cp $temp_dir/cyrus-sasl/config.h ./config/ios
