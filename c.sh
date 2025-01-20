#!/bin/bash

# 获取 Info.plist 中的当前 Build 版本号
BUILD_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")

# 检查是否成功获取到当前 Build 版本号
if [ -z "$BUILD_VERSION" ]; then
  echo "Error: CFBundleVersion not found in Info.plist"
  exit 1
fi

# 递增当前的 Build 版本号
NEW_BUILD_VERSION=$((BUILD_VERSION + 1))

# 更新 Info.plist 中的 Build 版本号
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD_VERSION" "${PROJECT_DIR}/${INFOPLIST_FILE}"

echo "Build version updated to: $NEW_BUILD_VERSION"




if [ $CONFIGURATION == Release ]; then
echo "Bumping build number..."
plist=${PROJECT_DIR}/${INFOPLIST_FILE}

#increment the build number (ie 115 to 116)
buildnum=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${plist}")
if [[ "${buildnum}" == "" ]]; then
echo "No build number in $plist"
exit 2
fi

buildnum=$(expr $buildnum + 1)
/usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildnum" "${plist}"
echo "Bumped build number to $buildnum"

else
echo $CONFIGURATION " build - Not bumping build number."

fi


# Define the path to the Info.plist file (change if necessary)
INFOPLIST_PATH="${PROJECT_DIR}/${INFOPLIST_FILE}"

# Get the current build version from Info.plist
CURRENT_BUILD_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_PATH")

# Check if the current build version exists and is a valid number
if [[ -z "$CURRENT_BUILD_VERSION" || ! "$CURRENT_BUILD_VERSION" =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid or missing CFBundleVersion in Info.plist"
  exit 1
fi

# Increment the build version number
NEW_BUILD_VERSION=$((CURRENT_BUILD_VERSION + 1))

# Set the new build version in Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD_VERSION" "$INFOPLIST_PATH"

echo "Build version updated to: $NEW_BUILD_VERSION"