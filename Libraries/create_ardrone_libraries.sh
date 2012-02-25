#!/bin/sh

SCRIPT_DIR=$(cd `dirname $0` && pwd)
ARDRONE_SOFT_BUILD_DIR="$SCRIPT_DIR/ARDroneSDK/ARDroneLib/Soft/Build"

cd "$ARDRONE_SOFT_BUILD_DIR"/; make clean RELEASE_BUILD=no ARDRONE_TARGET_OS=macosx ARDRONE_TARGET_ARCH=x86_64 USE_MACOSX=yes; cd -;
cd "$ARDRONE_SOFT_BUILD_DIR"/; make clean RELEASE_BUILD=no ARDRONE_TARGET_OS=macosx ARDRONE_TARGET_ARCH=i386 USE_MACOSX=yes; cd -;
rm -rf "$ARDRONE_SOFT_BUILD_DIR"/targets_versions

cd "$ARDRONE_SOFT_BUILD_DIR"/; make RELEASE_BUILD=no ARDRONE_TARGET_OS=macosx ARDRONE_TARGET_ARCH=x86_64 USE_MACOSX=yes; cd -
cd "$ARDRONE_SOFT_BUILD_DIR"/; make RELEASE_BUILD=no ARDRONE_TARGET_OS=macosx ARDRONE_TARGET_ARCH=i386 USE_MACOSX=yes; cd -

lipo -arch i386 "$ARDRONE_SOFT_BUILD_DIR"/targets_versions/vlib_DEBUG_MODE_i386_Darwin_11.2.0_Developerusrbingcc_4.2.1/libvlib.a -arch x86_64 "$ARDRONE_SOFT_BUILD_DIR"/targets_versions/vlib_DEBUG_MODE_x86_64_Darwin_11.2.0_Developerusrbingcc_4.2.1/libvlib.a -create -output "$SCRIPT_DIR"/libvlib.a
lipo -arch i386 "$ARDRONE_SOFT_BUILD_DIR"/targets_versions/sdk_DEBUG_MODE_vlib_i386_Darwin_11.2.0_Developerusrbingcc_4.2.1/libsdk.a -arch x86_64 "$ARDRONE_SOFT_BUILD_DIR"/targets_versions/sdk_DEBUG_MODE_vlib_x86_64_Darwin_11.2.0_Developerusrbingcc_4.2.1/libsdk.a -create -output "$SCRIPT_DIR"/libsdk.a
lipo -arch i386 "$ARDRONE_SOFT_BUILD_DIR"/targets_versions/ardrone_lib_DEBUG_MODE_vlib_i386_Darwin_11.2.0_Developerusrbingcc_4.2.1/libpc_ardrone.a -arch x86_64 "$ARDRONE_SOFT_BUILD_DIR"/targets_versions/ardrone_lib_DEBUG_MODE_vlib_x86_64_Darwin_11.2.0_Developerusrbingcc_4.2.1/libpc_ardrone.a -create -output "$SCRIPT_DIR"/libpc_ardrone.a