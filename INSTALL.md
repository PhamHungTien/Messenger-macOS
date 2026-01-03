# Installation Guide

## Messenger for macOS

Complete installation instructions for Messenger on macOS.

### System Requirements
- macOS 12.0 or later
- Mac with Apple Silicon or Intel processor

### Installation from DMG

1. **Download DMG file**
   - Visit [GitHub Releases](../../releases)
   - Download `Messenger-X.X.X.dmg` (latest version)

2. **Open DMG file**
   - Double-click the `Messenger-X.X.X.dmg` file
   - A Finder window will open

3. **Install application**
   - You'll see two items in the window:
     - `Messenger` icon (the application)
     - `Applications` icon (folder shortcut)
   - Drag the `Messenger` icon to the `Applications` folder
   - Alternatively, drag to your Applications folder in Finder

4. **"Can't be opened because it is from an unidentified developer" error?**
   - Open System Preferences → Security & Privacy
   - Click "Open Anyway" button
   - Confirm by entering your admin password

5. **Launch the application**
   - Open Finder → Applications
   - Find "Messenger"
   - Double-click to launch

6. **Switch modes (optional)**
   - Default: App runs in Dock mode
   - Right-click → Preferences
   - Select "Menu Bar Only" to run only in menu bar

### Installation from Source Code

#### Requirements:
- Xcode 15.0 or later
- macOS 12.0 SDK

#### Installation steps:

```bash
# Clone repository
git clone https://github.com/yourusername/Messenger.git
cd Messenger

# Open project in Xcode
open Messenger.xcodeproj

# Or build from command line
xcodebuild -scheme Messenger -configuration Release

# Find app at:
# ~/Library/Developer/Xcode/DerivedData/Messenger-xxx/Build/Products/Release/Messenger.app
```

### Build DMG for Distribution

```bash
# From project directory
./build_dmg.sh

# Or use Python script
python3 create_dmg.py
```

### Uninstallation

1. Open Finder → Applications
2. Find "Messenger"
3. Drag to Trash or right-click → Move to Trash

### Troubleshooting

#### Error: "Messenger has a problem"
- Try reinstalling the application
- Check your internet connection

#### Application won't launch
- Open Terminal
- Run: `open /Applications/Messenger.app`
- Check error messages

#### Notifications not working
- Check: System Preferences → Notifications & Focus
- Find "Messenger" in the list
- Enable notifications if disabled

### Updating the Application

When a new version is released:
1. Download new DMG file
2. Drag new app to Applications (replace old one)
3. Launch new version

### Useful Links

- [GitHub Repository](../../)
- [Issues & Bug Reports](../../issues)
- [Discussions](../../discussions)
- [GPL-3.0 License](LICENSE)

---

**Note:** This is an unofficial application and is not affiliated with Facebook/Meta.
