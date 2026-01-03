#!/bin/bash

# Build and Create DMG Installer for Messenger
# This script builds the app and creates a DMG installer with Applications folder shortcut

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"
BUILD_DIR="$PROJECT_ROOT/build"
DERIVED_DATA_PATH="$BUILD_DIR/DerivedData"
ARCHIVE_PATH="$BUILD_DIR/Messenger.xcarchive"
EXPORT_DIR="$BUILD_DIR/Export"
DMG_SOURCE="$BUILD_DIR/dmg_source"
DMG_FILE="$BUILD_DIR/Messenger-1.0.dmg"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Messenger build and DMG creation...${NC}"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build archive
echo -e "${YELLOW}Building archive...${NC}"
xcodebuild \
    -project "$PROJECT_ROOT/Messenger.xcodeproj" \
    -scheme "Messenger" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    archive

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}Archive creation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Archive created successfully${NC}"

# Export app from archive
echo -e "${YELLOW}Exporting app from archive...${NC}"
mkdir -p "$EXPORT_DIR"
xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$PROJECT_ROOT/ExportOptions.plist" \
    -exportPath "$EXPORT_DIR"

if [ ! -d "$EXPORT_DIR/Messenger.app" ]; then
    echo -e "${RED}App export failed!${NC}"
    exit 1
fi

echo -e "${GREEN}App exported successfully${NC}"

# Create DMG
echo -e "${YELLOW}Creating DMG...${NC}"
rm -rf "$DMG_SOURCE"
mkdir -p "$DMG_SOURCE"

# Copy app to DMG source
cp -r "$EXPORT_DIR/Messenger.app" "$DMG_SOURCE/"

# Create Applications symlink
ln -s /Applications "$DMG_SOURCE/Applications"

# Create DMG
rm -f "$DMG_FILE"
hdiutil create \
    -volname "Messenger" \
    -srcfolder "$DMG_SOURCE" \
    -ov \
    -format UDZO \
    "$DMG_FILE"

if [ ! -f "$DMG_FILE" ]; then
    echo -e "${RED}DMG creation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}DMG created successfully at: $DMG_FILE${NC}"
echo -e "${GREEN}File size: $(du -h "$DMG_FILE" | cut -f1)${NC}"

# Cleanup temporary files
rm -rf "$DMG_SOURCE" "$DERIVED_DATA_PATH"

echo -e "${GREEN}Build complete!${NC}"
echo -e "${YELLOW}You can now distribute: $DMG_FILE${NC}"
