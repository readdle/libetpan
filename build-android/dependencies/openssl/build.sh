#!/bin/sh

build_version=swift-toolchain
package_name=openssl-android

rm -rf $package_name-$build_version
mkdir -p $package_name-$build_version/include/
mkdir -p $package_name-$build_version/libs/arm64-v8a
mkdir -p $package_name-$build_version/libs/armeabi-v7a
mkdir -p $package_name-$build_version/libs/x86_64
mkdir -p $package_name-$build_version/libs/x86

cp -r $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/openssl ./$package_name-$build_version/include/

cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/armv7/libcrypto.a ./$package_name-$build_version/libs/armeabi-v7a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/armv7/libssl.a ./$package_name-$build_version/libs/armeabi-v7a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/aarch64/libcrypto.a ./$package_name-$build_version/libs/arm64-v8a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/aarch64/libssl.a ./$package_name-$build_version/libs/arm64-v8a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/i686/libcrypto.a ./$package_name-$build_version/libs/x86
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/i686/libssl.a ./$package_name-$build_version/libs/x86
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/x86_64/libcrypto.a ./$package_name-$build_version/libs/x86_64
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/x86_64/libssl.a ./$package_name-$build_version/libs/x86_64

cd "$current_dir"
zip -qry "$package_name-$build_version.zip" "$package_name-$build_version"
