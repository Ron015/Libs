#!/bin/bash

set -e

API_LEVEL=21
HOST_TAG=linux-x86_64
TARGET_ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

# Create output directory
mkdir -p android

for ABI in "${TARGET_ABIS[@]}"; do
    case $ABI in
        arm64-v8a)
            ARCH=aarch64
            TARGET=aarch64-linux-android
            ;;
        armeabi-v7a)
            ARCH=arm
            TARGET=armv7a-linux-androideabi
            ;;
        x86_64)
            ARCH=x86_64
            TARGET=x86_64-linux-android
            ;;
        x86)
            ARCH=i686
            TARGET=i686-linux-android
            ;;
    esac

    echo "Building for $ABI..."
    
    TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
    CC=$TOOLCHAIN/bin/${TARGET}${API_LEVEL}-clang
    CXX=$TOOLCHAIN/bin/${TARGET}${API_LEVEL}-clang++
    AR=$TOOLCHAIN/bin/llvm-ar
    RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    STRIP=$TOOLCHAIN/bin/llvm-strip

    ./configure \
        --host=$TARGET \
        --prefix=$(pwd)/android/$ABI \
        --disable-shared \
        --enable-static \
        --disable-verbose \
        --enable-ipv6 \
        CFLAGS="-fPIC -D__ANDROID_API__=$API_LEVEL" \
        CC="$CC" \
        AR="$AR" \
        RANLIB="$RANLIB" \
        STRIP="$STRIP"

    make clean
    make -j$(nproc)
    make install
    
    echo "Build for $ABI completed"
done