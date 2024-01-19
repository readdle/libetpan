#!/bin/sh

set -ex

current_dir="$(dirname "$0")"
temp_dir="/tmp/libetpan"
cd $current_dir

rm -rf $temp_dir
mkdir -p $temp_dir

# Configure libetpan
cp -r ./* $temp_dir
pushd $temp_dir
	# Build sasl2
	xcodebuild build -scheme sasl2 -sdk iphonesimulator16.2 -destination "OS=16.2,name=iPhone 14" -derivedDataPath ./.build-ios

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

	# # Build OpenSSL with Shared library
	# # Unforunetly SASL configure works only with shared library
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

    # Prepare SASL2 install
    mkdir -p ./sasl-install/lib
    cp -r dependencies/sasl2/include sasl-install/
    cp .build-ios/Build/Products/Debug-iphonesimulator/sasl2.o sasl-install/lib/

    # Configure libetpan
	./autogen.sh --with-curl=no --disable-db --with-expat=no --host=$TARGET_TRIPLE --with-openssl=./openssl-install --with-sasl=./sasl-install --enable-iconv

	pushd include
		make
	popd
popd

cp $temp_dir/config.h ./config/ios
cp -r -L $temp_dir/include/libetpan ./include

rm -rf ./include/libetpan/clientid.h
rm -rf ./include/libetpan/imapdriver_tools.h
rm -rf ./include/libetpan/imapdriver_tools_private.h
rm -rf ./include/libetpan/mail.h
rm -rf ./include/libetpan/mailstream_compress.h
rm -rf ./include/libetpan/mailstream_parser.h
rm -rf ./include/libetpan/mailstream_sender.h
rm -rf ./include/libetpan/namespace_parser.h
rm -rf ./include/libetpan/namespace_sender.h
rm -rf ./include/libetpan/quota_parser.h
rm -rf ./include/libetpan/quota_sender.h