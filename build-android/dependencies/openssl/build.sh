#!/bin/sh

build_version=swift-toolchain
package_name=openssl-android

rm -rf $package_name-$build_version
mkdir -p $package_name-$build_version/include/
mkdir -p $package_name-$build_version/libs/arm64-v8a
mkdir -p $package_name-$build_version/libs/armeabi-v7a
mkdir -p $package_name-$build_version/libs/x86_64
mkdir -p $package_name-$build_version/libs/x86

cp -r $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-aarch64/openssl ./$package_name-$build_version/include/

cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-armv7/android/libcrypto.a ./$package_name-$build_version/libs/armeabi-v7a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-armv7/android/libssl.a ./$package_name-$build_version/libs/armeabi-v7a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-aarch64/android/libcrypto.a ./$package_name-$build_version/libs/arm64-v8a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-aarch64/android/libssl.a ./$package_name-$build_version/libs/arm64-v8a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-i686/android/libcrypto.a ./$package_name-$build_version/libs/x86
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-i686/android/libssl.a ./$package_name-$build_version/libs/x86
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-x86_64/android/libcrypto.a ./$package_name-$build_version/libs/x86_64
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift-x86_64/android/libssl.a ./$package_name-$build_version/libs/x86_64

cd "$current_dir"
zip -qry "$package_name-$build_version.zip" "$package_name-$build_version"
