#!/bin/bash

set -ex

current_dir="$(dirname "$0")"
temp_dir="/tmp/libetpan-deps"
cd $current_dir

rm -rf $temp_dir
mkdir -p $temp_dir

# Requires the OpenSSL development package (libssl-dev) on the Linux host
cp -r cyrus-sasl $temp_dir/cyrus-sasl
pushd $temp_dir
	# Configure SASL for Linux
	pushd cyrus-sasl
		./autogen.sh \
			--enable-login \
			--enable-ntlm \
			--enable-gssapi=no \
			--with-dblib=none \
			--enable-static
	popd
popd

# Copy config.h and fix TIME_WITH_SYS_TIME (bug in configure)
mkdir -p ./config/linux
cp $temp_dir/cyrus-sasl/config.h ./config/linux
sed -i 's/HAVE_SYS_TIME_H 1/TIME_WITH_SYS_TIME 1/g' ./config/linux/config.h
