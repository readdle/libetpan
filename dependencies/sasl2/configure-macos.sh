#!/bin/sh

set -ex

current_dir="$(dirname "$0")"
temp_dir="/tmp/libetpan-deps"
cd $current_dir

rm -rf $temp_dir
mkdir -p $temp_dir

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
    	./Configure darwin64-arm64-cc --prefix=$temp_dir/openssl-install
    	make && make install_sw
    popd

	pushd cyrus-sasl
		./autogen.sh --with-openssl=$temp_dir/openssl-install \
			--enable-login \
			--enable-ntlm \
			--enable-gssapi=no \
			--with-dblib=none \
			--enable-static
	popd
popd

cp $temp_dir/cyrus-sasl/config.h ./config/macos