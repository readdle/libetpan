#!/bin/bash

set -ex

current_dir="$(dirname "$0")"
temp_dir="/tmp/libetpan"
cd $current_dir

rm -rf $temp_dir
mkdir -p $temp_dir

# Requires the OpenSSL and Cyrus SASL development packages (libssl-dev, libsasl2-dev) on the Linux host
cp -r ./* $temp_dir
pushd $temp_dir
	# Configure libetpan for Linux
	./autogen.sh --with-curl=no --disable-db --with-expat=no --with-openssl --with-sasl --enable-iconv --with-poll
popd

mkdir -p ./config/linux
cp $temp_dir/config.h ./config/linux
