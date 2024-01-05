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

# Configure iconv for Android
cp -r libiconv $temp_dir/libiconv
pushd $temp_dir/libiconv
	./autogen.sh --host=$TARGET
	./configure --host=$TARGET
popd

# Copy public header
cp $temp_dir/libiconv/include/iconv.h ./include/android

# Copy config headers
cp $temp_dir/libiconv/config.h ./config/android
cp $temp_dir/libiconv/libcharset/include/localcharset.h ./config/android
cp $temp_dir/libiconv/lib/translit.h ./config/android
cp $temp_dir/libiconv/lib/flags.h ./config/android
cp $temp_dir/libiconv/lib/aliases.h ./config/android
cp $temp_dir/libiconv/lib/canonical.h ./config/android
cp $temp_dir/libiconv/lib/canonical_local.h ./config/android
