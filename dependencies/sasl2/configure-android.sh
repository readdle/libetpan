#!/bin/sh

set -ex

current_dir="$(dirname "$0")"
temp_dir="/tmp/libetpan-deps"
cd $current_dir

rm -rf $temp_dir
mkdir -p $temp_dir

export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/darwin-x86_64
export TARGET=aarch64-linux-android
export API=24
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
PATH=$TOOLCHAIN/bin:$PATH

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
	OPENSSL_VERSION=1.1.1w
	DOWNLOAD_URL_OPENSSL=https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
	wget $DOWNLOAD_URL_OPENSSL -O openssl.tar.gz
	tar -xvf openssl.tar.gz -C openssl --strip-components=1
   	pushd openssl
    	./Configure android-arm64 -D__ANDROID_API__=$API \
    	    no-engine \
    	    zlib \
    	    --prefix=$temp_dir/openssl-install
    	make && make install_sw
    popd

	# Configure SASL for Android
	pushd cyrus-sasl
		./autogen.sh --host=$TARGET \
			--with-openssl=$temp_dir/openssl-install \
			--enable-login \
			--enable-ntlm \
			--enable-gssapi=no \
			--with-dblib=none \
			--enable-static
	popd
popd

# Copy config.h and fix TIME_WITH_SYS_TIME on Android (bug in configure)
cp $temp_dir/cyrus-sasl/config.h ./config/android
sed -i '' 's/HAVE_SYS_TIME_H 1/TIME_WITH_SYS_TIME 1/g' ./config/android/config.h
