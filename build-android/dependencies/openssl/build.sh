#!/bin/sh

build_version=3
package_name=openssl-android

rm -rf $package_name-$build_version
mkdir -p $package_name-$build_version/include/
mkdir -p $package_name-$build_version/libs/arm64-v8a
mkdir -p $package_name-$build_version/libs/armeabi-v7a
mkdir -p $package_name-$build_version/libs/x86_64

cp -r $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/openssl ./$package_name-$build_version/include/

cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/armv7/libcrypto.a ./$package_name-$build_version/libs/armeabi-v7a/libcrypto.a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/armv7/libssl.a ./$package_name-$build_version/libs/armeabi-v7a/libssl.a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/aarch64/libcrypto.a ./$package_name-$build_version/libs/arm64-v8a/libcrypto.a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/aarch64/libssl.a ./$package_name-$build_version/libs/arm64-v8a/libssl.a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/x86/libcrypto.a ./$package_name-$build_version/libs/x86_64/libcrypto.a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/x86/libssl.a ./$package_name-$build_version/libs/x86_64/libssl.a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/x86_64/libcrypto.a ./$package_name-$build_version/libs/x86_64/libcrypto.a
cp $SWIFT_ANDROID_HOME/toolchain/usr/lib/swift/android/x86_64/libssl.a ./$package_name-$build_version/libs/x86_64/libssl.a

cd "$current_dir"
zip -qry "$package_name-$build_version.zip" "$package_name-$build_version"
rm -rf "$package_name-$build_version"
