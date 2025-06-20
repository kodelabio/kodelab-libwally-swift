#!/usr/bin/env sh
set -e # abort if any command fails

BIN_OUTPUT_DIRECTORY="`pwd`/build"

rm -rf $BIN_OUTPUT_DIRECTORY

git submodule update --init --recursive

# — iOS Simulator slice (arm64 + x86_64) —
xcodebuild archive -scheme LibWally \
  -destination "generic/platform=iOS Simulator" \
  -archivePath ${BIN_OUTPUT_DIRECTORY}/LibWally-Sim \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym


# — iOS device slice (arm64) —
xcodebuild archive -scheme LibWally \
  -destination "generic/platform=iOS" \
  -archivePath ${BIN_OUTPUT_DIRECTORY}/LibWally-iOS \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym

xcodebuild -create-xcframework \
  -framework  "${BIN_OUTPUT_DIRECTORY}/LibWally-iOS.xcarchive/Products/Library/Frameworks/LibWally.framework" \
  -debug-symbols "${BIN_OUTPUT_DIRECTORY}/LibWally-iOS.xcarchive/dSYMs/LibWally.framework.dSYM" \
  -framework  "${BIN_OUTPUT_DIRECTORY}/LibWally-Sim.xcarchive/Products/Library/Frameworks/LibWally.framework" \
  -debug-symbols "${BIN_OUTPUT_DIRECTORY}/LibWally-Sim.xcarchive/dSYMs/LibWally.framework.dSYM" \
  -output "${BIN_OUTPUT_DIRECTORY}/LibWally.xcframework"
