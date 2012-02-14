#!/bin/sh

ARDRONE_LIB_PATH='./Libraries/ARDroneLib'

if [ ! -d $ARDRONE_LIB_PATH ] ; then
echo "$ARDRONE_LIB_PATH does not exist ! Checkout it with svn !"
exit 1
fi

echo $CURRENT_ARCH
echo ${EFFECTIVE_PLATFORM_NAME:1} ${CURRENT_ARCH:0:4}
EFFECTIVE_PLATFORM_NAME="MacOSX"

export ARDRONE_TARGET_OS=${EFFECTIVE_PLATFORM_NAME:1}
if [ ${CONFIGURATION} = "Release" ]; then
export RELEASE_BUILD=yes
else 	
export RELEASE_BUILD=no
fi

export ARDRONE_TARGET_OS_FORMAT=$ARDRONE_TARGET_OS CONFIGURATION_BUILD_DIR
export ARDRONE_TARGET_OS_FORMAT=`echo $ARDRONE_TARGET_OS_FORMAT | sed -e "s/iphone/iPhone/g"`
export ARDRONE_TARGET_OS_FORMAT=`echo $ARDRONE_TARGET_OS_FORMAT | sed -e "s/os/OS/g"`
export ARDRONE_TARGET_OS_FORMAT=`echo $ARDRONE_TARGET_OS_FORMAT | sed -e "s/simulator/Simulator/g"`
echo "ARDRONE_TARGET_OS_FORMAT is $ARDRONE_TARGET_OS_FORMAT"

export ARDRONE_TARGET_BUILD=$RELEASE_BUILD
echo "RELEASE_BUILD is $RELEASE_BUILD"
export ARDRONE_TARGET_BUILD=`echo $ARDRONE_TARGET_BUILD | sed -e "s/yes/PROD_MODE/g"`
export ARDRONE_TARGET_BUILD=`echo $ARDRONE_TARGET_BUILD | sed -e "s/no/DEBUG_MODE/g"`
echo "ARDRONE_TARGET_BUILD is $ARDRONE_TARGET_BUILD"

if [ ! -d $TARGET_BUILD_DIR ] ; then
echo "Create "$TARGET_BUILD_DIR" directory."
mkdir $TARGET_BUILD_DIR	
fi

cd $ARDRONE_LIB_PATH/Soft/Build

# Compiling for i386/osx
echo "Compiling ARDroneLib with options IPHONE_MODE = yes - IPHONE_SDK_PATH=${SDK_DIR} - RELEASE_BUILD = "$RELEASE_BUILD" - ARDRONE_TARGET_OS=$EFFECTIVE_PLATFORM_NAME - ARDRONE_TARGET_ARCH="${CURRENT_ARCH}"."
make IPHONE_MODE=no IPHONE_SDK_PATH=${SDK_DIR} RELEASE_BUILD=$RELEASE_BUILD ARDRONE_TARGET_OS=$EFFECTIVE_PLATFORM_NAME ARDRONE_TARGET_ARCH=${CURRENT_ARCH}

cd -
export ARDRONE_ARDRONELIB_PATH="$ARDRONE_LIB_PATH/Soft/Build/targets_versions/ardrone_lib_"$ARDRONE_TARGET_BUILD"_vlib_"${CURRENT_ARCH}"_"$ARDRONE_TARGET_OS"_DeveloperPlatforms"$ARDRONE_TARGET_OS_FORMAT".platformDeveloperusrbingcc_4.2.1"
export ARDRONE_SDKDEV_PATH="$ARDRONE_LIB_PATH/Soft/Build/targets_versions/sdk_"$ARDRONE_TARGET_BUILD"_vlib_"${CURRENT_ARCH}"_"$ARDRONE_TARGET_OS"_DeveloperPlatforms"$ARDRONE_TARGET_OS_FORMAT".platformDeveloperusrbingcc_4.2.1"
export ARDRONE_VLIB_PATH="$ARDRONE_LIB_PATH/Soft/Build/targets_versions/vlib_"$ARDRONE_TARGET_BUILD"_"${CURRENT_ARCH}"_"$ARDRONE_TARGET_OS"_DeveloperPlatforms"$ARDRONE_TARGET_OS_FORMAT".platformDeveloperusrbingcc_4.2.1"
cp $ARDRONE_ARDRONELIB_PATH/libpc_ardrone.a $TARGET_BUILD_DIR/
cp $ARDRONE_SDKDEV_PATH/libsdk.a $TARGET_BUILD_DIR/
cp $ARDRONE_VLIB_PATH/libvlib.a $TARGET_BUILD_DIR/
fi

exit 0

echo "Generate files needed by ARDroneEngine."
rm -Rf Release/ARDroneGeneratedTypes.h
touch Release/ARDroneGeneratedTypes.h
echo "// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> Release/ARDroneGeneratedTypes.h
echo "// !!!! THIS FILE IS GENERATED AUTOMATICALLY, DO NOT CHANGE IT !!!!" >> Release/ARDroneGeneratedTypes.h
echo "// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> Release/ARDroneGeneratedTypes.h
echo "/*" >> Release/ARDroneGeneratedTypes.h
echo " *  ARDroneGeneratedTypes.h" >> Release/ARDroneGeneratedTypes.h
echo " *  ARDroneEngine" >> Release/ARDroneGeneratedTypes.h
echo " *" >> Release/ARDroneGeneratedTypes.h
echo " *  Automatically generated." >> Release/ARDroneGeneratedTypes.h
echo " *  Copyright 2010 Parrot SA. All rights reserved." >> Release/ARDroneGeneratedTypes.h
echo " *" >> Release/ARDroneGeneratedTypes.h
echo " */" >> Release/ARDroneGeneratedTypes.h
echo "#ifndef _ARDRONE_GENERATED_TYPES_H_" >> Release/ARDroneGeneratedTypes.h
echo "#define _ARDRONE_GENERATED_TYPES_H_" >> Release/ARDroneGeneratedTypes.h

echo ""  >> Release/ARDroneGeneratedTypes.h
grep -r ^\#define $ARDRONE_LIB_PATH/Soft/Common/navdata_common.h | grep NB_NAVDATA_DETECTION_RESULTS | sed 's/^\#define NB_NAVDATA_DETECTION_RESULTS \(.*\)/\#define ARDRONE_MAX_ENEMIES \1/g' | sed 's/\/\*.*\*\///' >> Release/ARDroneGeneratedTypes.h

echo ""  >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r ^LED_ANIMATION\( $ARDRONE_LIB_PATH/Soft/Common/led_animation.h | tr -d ' ' | tr -d '\t' | sed 's/^LED_ANIMATION(\([A-Za-z_0-9=]*\),\(.*\))/ARDRONE_LED_ANIMATION_\1,/g' | sed 's/\/\*.*\*\///' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_LED_ANIMATION;" >> Release/ARDroneGeneratedTypes.h

echo ""  >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r "\s*ARDRONE_ANIM_" $ARDRONE_LIB_PATH/Soft/Common/config.h | tr -d ' ' | tr -d '\t' | sed 's/^ARDRONE_ANIM_\([A-Za-z_0-9=,]*\)/ARDRONE_ANIMATION_\1/' | sed 's/^ARDRONE_ANIM_\([A-Za-z_0-9,]*\)/ARDRONE_ANIMATION_\1/' | sed 's/\/\*.*\*\///' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_ANIMATION;" >> Release/ARDroneGeneratedTypes.h

echo ""  >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r "\s*CAD_TYPE_" $ARDRONE_LIB_PATH/Soft/Common/ardrone_api.h | tr -d ' ' | tr -d '\t' | sed 's/^CAD_TYPE_\([A-Za-z_0-9=,]*\)/ARDRONE_CAMERA_DETECTION_\1/' | sed 's/^CAD_TYPE_\([A-Za-z_0-9,]*\)/ARDRONE_CAMERA_DETECTION_\1/' | sed 's/\/\*.*\*\///' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_CAMERA_DETECTION_TYPE;" >> Release/ARDroneGeneratedTypes.h

echo ""  >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r "\s*ZAP_CHANNEL_" $ARDRONE_LIB_PATH/Soft/Common/ardrone_api.h | tr -d ' ' | tr -d '\t' | sed 's/ZAP_CHANNEL_\([A-Za-z_0-9=,]*\)/ARDRONE_VIDEO_CHANNEL_\1/' | sed 's/ZAP_CHANNEL_\([A-Za-z_0-9,]*\)/ARDRONE_VIDEO_CHANNEL_\1/' | sed 's/\/\*.*\*\///' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_VIDEO_CHANNEL;" >> Release/ARDroneGeneratedTypes.h

echo ""  >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r "\s*VBC_" $ARDRONE_LIB_PATH/Soft/Common/ardrone_api.h | tr -d ' ' | tr -d '\t' | sed 's/VBC_\([A-Za-z_0-9=,]*\)/ARDRONE_VARIABLE_BITRATE_\1/' | sed 's/VBC_\([A-Za-z_0-9,]*\)/ARDRONE_VARIABLE_BITRATE_\1/' | sed 's/\/\*.*\*\///' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_VARIABLE_BITRATE;" >> Release/ARDroneGeneratedTypes.h

echo ""  >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r "\s*ARDRONE_DETECTION_COLOR_" $ARDRONE_LIB_PATH/Soft/Common/ardrone_api.h | tr -d ' ' | tr -d '\t' | sed 's/ARDRONE_DETECTION_COLOR_\([A-Za-z_0-9=,]*\)/ARDRONE_ENEMY_COLOR_\1/' | sed 's/ARDRONE_DETECTION_COLOR_\([A-Za-z_0-9,]*\)/ARDRONE_ENEMY_COLOR_\1/' | sed 's/\/\*.*\*\///' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_ENEMY_COLOR;" >> Release/ARDroneGeneratedTypes.h

echo ""  >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r ^ARDRONE_CONFIG_KEY_ $ARDRONE_LIB_PATH/Soft/Common/config_keys.h | tr -d ' ' | tr -d '\t' | tr '[:lower:]' '[:upper:]' | grep K_WRITE | grep -e CONTROL -e NETWORK -e VIDEO -e LEDS -e DETECT -e GPS | sed 's/^ARDRONE_CONFIG_KEY_\([IMM|STR]*\)\(_A10\)*("\([A-Za-z_0-9=",]*\)",\([A-Za-z_0-9=]*\),INI_\([A-Za-z_0-9=]*\),\(.*\))/ARDRONE_CONFIG_KEY_\4,\/\/\5/g' | sed 's/\/\*.*\*\///' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_CONFIG_KEYS;" >> Release/ARDroneGeneratedTypes.h

echo "" >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r _CODEC.*\ *=\ *0x $ARDRONE_LIB_PATH/VLIB/video_codec.h | tr -d ' ' | tr -d '\t' | sed 's/\([a-zA-Z0-9]*\)_CODEC=0x\([0-9]*\).*/ARDRONE_VIDEO_CODEC_\1\ =\ 0x\2,/g' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_VIDEO_CODEC;" >> Release/ARDroneGeneratedTypes.h

echo "" >> Release/ARDroneGeneratedTypes.h
echo "typedef enum {" >> Release/ARDroneGeneratedTypes.h
grep -r FLYING_MODE_.*, $ARDRONE_LIB_PATH/Soft/Common/ardrone_api.h | tr -d ' ' | tr -d '\t' | sed 's:FLYING_MODE_\(.*\),/.*:ARDRONE_FLYING_MODE_\1,:g' >> Release/ARDroneGeneratedTypes.h
echo "} ARDRONE_FLYING_MODE;" >> Release/ARDroneGeneratedTypes.h

echo "#endif // _ARDRONE_GENERATED_TYPES_H_" >> Release/ARDroneGeneratedTypes.h

KEY_FILE=$ARDRONE_LIB_PATH/Soft/Common/config_keys.h
TYPES_FILE=Release/ARDroneTypes.h
OUT_FILE=Release/ARDroneGeneratedCommandIn.h

TEMP_FILE=TEMPORARY

rm -f $OUT_FILE
rm -f $TEMP_FILE
touch $OUT_FILE
touch $TEMP_FILE

grep -r ^ARDRONE_CONFIG_KEY_ $KEY_FILE | grep K_WRITE | grep -e control -e network -e video -e leds -e detect -e gps | tr ',' ' ' >> $TEMP_FILE
awk '
BEGIN {
print "// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
print "// !!!! THIS FILE IS GENERATED AUTOMATICALLY, DO NOT CHANGE IT !!!!";
print "// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
print "/*";
print " *  ARDroneGeneratedCommandIn.h";
print " *  ARDroneEngine";
print " *";
print " *  Automatically generated.";
print " *  Copyright 2011 Parrot SA. All rights reserved";
print " *";
print " */";
print "";
print "#ifdef COMMAND_IN_CONFIG_KEY";
print "#ifdef COMMAND_IN_CONFIG_KEY_STRING";

INT_VAR="none"
UNS_VAR="none"
BOOL_VAR="none"
FLOAT_VAR="none"
DOUBLE_VAR="none"
}

/^\/\/[\ \t]*MATCH_TYPES\ :/ {
match ($0, /:\ .*\ :/);
VAR_NAME=substr($0, RSTART+2, RLENGTH-3);
if ($0 ~ /[\ \t]int32_t/) { INT_VAR=VAR_NAME }
if ($0 ~ /bool_t/) { BOOL_VAR=VAR_NAME }
if ($0 ~ /float32_t/) { FLOAT_VAR=VAR_NAME }
if ($0 ~ /float64_t/) { DOUBLE_VAR=VAR_NAME }
if ($0 ~ /uint32_t/) { UNS_VAR=VAR_NAME }
}

/^ARDRONE_CONFIG_KEY_/ {
CASE_NAME="ARDRONE_CONFIG_KEY_" toupper($2);
CONFIG_KEY=$2;
TYPE=$4;
ARG_TYPE=""
TYPE_PRINT=""
if (TYPE ~ /^int32_t/) { ARG_TYPE=INT_VAR; TYPE_PRINT="EQUAL" }
else if (TYPE ~ /bool_t/) { ARG_TYPE=BOOL_VAR; TYPE_PRINT="EQUAL" }
else if (TYPE ~ /float32_t/) { ARG_TYPE=FLOAT_VAR; TYPE_PRINT="EQUAL" }
else if (TYPE ~ /float64_t/) { ARG_TYPE=DOUBLE_VAR; TYPE_PRINT="EQUAL" }
else if (TYPE ~ /string_t/) { ARG_TYPE=STRING_VAR; TYPE_PRINT="STRCPY" }
else if (TYPE ~ /uint32_t/) { ARG_TYPE=UNS_VAR; TYPE_PRINT="EQUAL" }
if (TYPE_PRINT ~ /EQUAL/) { print "COMMAND_IN_CONFIG_KEY (" CASE_NAME ", " CONFIG_KEY ", " ARG_TYPE ")" }
else if (TYPE_PRINT ~ /STRCPY/) { print "COMMAND_IN_CONFIG_KEY_STRING (" CASE_NAME ", " CONFIG_KEY " )" }
}

END {
print "#endif //COMMAND_IN_CONFIG_KEY_STRING";
print "#endif //COMMAND_IN_CONFIG_KEY";
}
' $TYPES_FILE $TEMP_FILE >> $OUT_FILE

rm -f $TEMP_FILE
