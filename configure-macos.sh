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
	# Build OpenSSL with Shared library
	# Unforunetly SASL configure works only with shared library
	mkdir -p $temp_dir/openssl
	mkdir -p $temp_dir/openssl-install
	OPENSSL_VERSION=1.1.1v
	DOWNLOAD_URL_OPENSSL=https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
	wget $DOWNLOAD_URL_OPENSSL -O openssl.tar.gz
	tar -xvf openssl.tar.gz -C openssl --strip-components=1
   	pushd openssl
    	./Configure darwin64-arm64-cc \
    	    zlib \
    	    --prefix=$temp_dir/openssl-install
    	make && make install_sw
    popd

    # Build sasl2
	swift build --product sasl2

    # Prepare SASL2 install
    mkdir -p ./sasl-install/lib
    cp -r dependencies/sasl2/include sasl-install/
    cp .build/debug/libsasl2.a sasl-install/lib/

    # Configure libetpan
	./autogen.sh --with-curl=no --disable-db --with-expat=no --with-openssl=$temp_dir/openssl-install --with-sasl=./sasl-install --enable-iconv --with-poll

	pushd include
		make
	popd
popd

cp $temp_dir/config.h ./config/macos
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