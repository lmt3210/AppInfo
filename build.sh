#!/bin/bash

VERSION=$(cat AppInfo.xcodeproj/project.pbxproj | \
          grep -m1 'MARKETING_VERSION' | cut -d'=' -f2 | \
          tr -d ';' | tr -d ' ')
ARCHIVE_DIR=/Users/Larry/Library/Developer/Xcode/Archives/CommandLine

rm -f make.log
touch make.log
rm -rf build

echo "Building AppInfo" 2>&1 | tee -a make.log

xcodebuild -project AppInfo.xcodeproj clean 2>&1 | tee -a make.log
xcodebuild -project AppInfo.xcodeproj \
    -scheme "AppInfo Release" -archivePath AppInfo.xcarchive \
    archive 2>&1 | tee -a make.log

rm -rf ${ARCHIVE_DIR}/AppInfo-v${VERSION}.xcarchive
cp -rf AppInfo.xcarchive ${ARCHIVE_DIR}/AppInfo-v${VERSION}.xcarchive

