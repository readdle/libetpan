#!/bin/sh

set -e

openssl_build_version=swift-toolchain # OpenSSL from swift toolchain
cyrus_sasl_build_version=2.1.27 # source code hardcoded in https://github.com/readdle/libetpan/tree/master/build-mac/dependencies/packages
iconv_build_version=1.15 # version hardcoded in https://github.com/readdle/libetpan/blob/master/build-android/dependencies/iconv/build.sh
package_name=libetpan-android

current_dir="`pwd`"

if test "x$ANDROID_NDK" = x ; then
  echo should set ANDROID_NDK before running this script.
  exit 1
fi

if test ! -f "$current_dir/dependencies/openssl/openssl-android-$openssl_build_version.zip" ; then
  echo Building OpenSSL first
  cd "$current_dir/dependencies/openssl"
  ./build.sh
fi

if test ! -f "$current_dir/dependencies/cyrus-sasl/cyrus-sasl-android-$cyrus_sasl_build_version.zip" ; then
  echo Building Cyrus SASL first
  cd "$current_dir/dependencies/cyrus-sasl"
  ./build.sh
fi

if test ! -f "$current_dir/dependencies/iconv/iconv-android-$iconv_build_version.zip" ; then
  echo Building ICONV first
  cd "$current_dir/dependencies/iconv"
  ./build.sh
fi

function build {
  rm -rf "$current_dir/obj"
  
  cd "$current_dir/jni"
  $ANDROID_NDK/ndk-build TARGET_PLATFORM=$ANDROID_PLATFORM TARGET_ARCH_ABI=$TARGET_ARCH_ABI \
    OPENSSL_PATH="$current_dir/third-party/openssl-android-$openssl_build_version" \
    CYRUS_SASL_PATH="$current_dir/third-party/cyrus-sasl-android-$cyrus_sasl_build_version" \
    ICONV_PATH="$current_dir/third-party/iconv-android-$iconv_build_version"

  mkdir -p "$current_dir/$package_name/libs/$TARGET_ARCH_ABI"
  cp "$current_dir/obj/local/$TARGET_ARCH_ABI/libetpan.a" "$current_dir/$package_name/libs/$TARGET_ARCH_ABI"
}

mkdir -p "$current_dir/third-party"
cd "$current_dir/third-party"
unzip -qo "$current_dir/dependencies/openssl/openssl-android-$openssl_build_version.zip"
unzip -qo "$current_dir/dependencies/cyrus-sasl/cyrus-sasl-android-$cyrus_sasl_build_version.zip"
unzip -qo "$current_dir/dependencies/iconv/iconv-android-$iconv_build_version.zip"

cd "$current_dir/.."
tar xzf "$current_dir/../build-mac/autogen-result.tar.gz"
./configure
make prepare

pushd "$current_dir/../include"
make
popd

# Copy public headers to include
cp -r include/libetpan "$current_dir/include"
mkdir -p "$current_dir/$package_name/include"
cp -r include/libetpan "$current_dir/$package_name/include"

# Start building.
ANDROID_PLATFORM=android-21
archs="armeabi-v7a arm64-v8a x86 x86_64"
for arch in $archs ; do
  TARGET_ARCH_ABI=$arch
  build
done

rm -rf "$current_dir/third-party"
