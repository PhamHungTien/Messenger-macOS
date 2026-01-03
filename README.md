# Messenger for macOS

<p align="center">
  <img src="Messenger/Resources/Messenger_menubar.png" alt="Messenger for macOS" width="128" height="128">
</p>

<p align="center">
  <strong>A native macOS application for Facebook Messenger</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

---

## Overview

**Messenger for macOS** is a native macOS application that brings Facebook Messenger to your desktop with true native integration. Unlike simple web wrappers, this app provides native macOS notifications with Quick Reply, menu bar mode, advanced keyboard shortcuts, and a modern design that follows Apple's Human Interface Guidelines.

Built to replace the discontinued Facebook Messenger Desktop app, this project demonstrates how to bridge web technologies with native macOS features to create a seamless user experience.

## Features

### 🔔 Native Notifications with Quick Reply

- **Web Notification Interception**: Captures web notifications and displays them as native macOS notifications
- **Quick Reply**: Respond directly from notification banners without opening the app
- **Rich Notifications**: Displays avatars and message previews
- **Action Buttons**: Reply, Mark as Read, and View actions
- **Always On Top**: Notifications appear even when the app is in the foreground

### 🎯 Menu Bar Mode

- **Menu Bar Only Mode**: Run the app exclusively in the menu bar without a Dock icon
- **Popover Window**: Click the menu bar icon to open a 380x600 popover window
- **Quick Access**: Right-click for settings and preferences
- **Badge Notifications**: Icon changes to indicate unread messages
- **Toggle Modes**: Easily switch between Dock mode and Menu Bar mode

### ⌨️ Advanced Keyboard Shortcuts

**Global Hotkey:**
- `Cmd+Shift+M`: Show/Hide app from anywhere

**Navigation:**
- `Cmd+Opt+↓`: Next conversation
- `Cmd+Opt+↑`: Previous conversation
- `Cmd+F`: Focus search
- `Cmd+K`: Focus message composer

**Quick Switch:**
- `Cmd+1` through `Cmd+5`: Jump to conversations 1-5

**Standard:**
- `Cmd+N`: New message
- `Cmd+C/V/X/A`: Copy/Paste/Cut/Select All

### 🎨 Modern Design

- **Hidden Title Bar**: Immersive full-screen experience without redundant UI
- **Edge-to-Edge WebView**: Full-screen WebView with Messenger.com managing its own UI
- **Minimal Chrome**: Only traffic light buttons, no UI duplication
- **Liquid Glass Ready**: Prepared for macOS 26 Liquid Glass API
- **Dark Mode**: Automatically follows system appearance

## Requirements

- **macOS**: 14.0 or later
- **Xcode**: 15.0 or later (for building from source)

## Installation

### Building from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/PhamHungTien/Messenger-macOS.git
   cd Messenger-macOS
   ```

2. Open the project in Xcode:
   ```bash
   open Messenger.xcodeproj
   ```

3. Build and run:
   - Select the "Messenger" target
   - Press `Cmd+R` to build and run
   - Grant notification permissions when prompted

### First Launch

1. **Grant Notification Permission**: The app will request notification permissions - click "Allow"
2. **Login to Messenger**: Sign in with your Facebook/Messenger account in the WebView
3. **Try Quick Reply**: When a new message arrives, reply directly from the notification
4. **Global Hotkey**: Press `Cmd+Shift+M` to show/hide the app from anywhere

## Installation

### From DMG (Recommended)

1. Download the latest `Messenger-X.X.X.dmg` from [Releases](../../releases)
2. Open the DMG file
3. Drag `Messenger.app` into the `Applications` folder
4. Launch from Applications or Spotlight (Cmd+Space)

For detailed installation instructions, see [INSTALL.md](INSTALL.md).

### From Source

```bash
git clone https://github.com/PhamHungTien/Messenger-macOS.git
cd Messenger
open Messenger.xcodeproj
```

## Usage

### Menu Bar Mode

1. Right-click the menu bar icon → Select "Menu Bar Mode"
2. The app will hide from the Dock and appear only in the menu bar
3. Click the icon to open the popover window
4. Toggle back to return to Dock mode

### Keyboard Shortcuts

All keyboard shortcuts are integrated into the macOS Command menu and work globally throughout the app. See the [Features](#features) section for the complete list.

## Architecture

### Design Philosophy

**Minimal Native Chrome, Maximum Web Fidelity**

The design philosophy centers on leveraging Messenger.com's complete UI while providing native macOS services:
- Messenger.com already has a complete UI with sidebar, search, and navigation
- The app provides a native container and services (notifications, shortcuts)
- No UI duplication → Clean, immersive experience

### File Structure

```
Messenger/
├── MessengerApp.swift             # Main app entry point
├── ContentView.swift              # Full-screen WebView container
├── AppDelegate.swift              # App lifecycle, menu bar integration
│
├── WebView.swift                  # WKWebView with JavaScript bridge
│   ├── Notification interception (web → native)
│   ├── Unread count tracking
│   └── Quick reply injection (native → web)
│
├── NotificationManager.swift      # Native macOS notifications
│   ├── UNUserNotificationCenter delegate
│   ├── Quick reply text input actions
│   └── Rich notifications with avatars
│
├── MenuBarManager.swift           # Menu bar mode implementation
│   ├── NSStatusItem management
│   ├── Popover window (380x600)
│   └── Event monitor for auto-close
│
├── KeyboardShortcutsManager.swift # Advanced keyboard shortcuts
│   ├── Carbon EventHotKey for global Cmd+Shift+M
│   ├── Navigation shortcuts (Cmd+Opt+↓/↑, Cmd+1-5)
│   └── Focus management (Cmd+F, Cmd+K)
│
├── WebViewManager.swift           # WebView state management
├── DraggableWindowView.swift      # Custom window dragging
├── LiquidGlassModifiers.swift     # Optional glass effects
├── GlassToolbar.swift             # Reference component
├── Messenger.entitlements         # App permissions
└── Assets.xcassets/               # App icons and images
```

### Technical Implementation

For detailed implementation guides, see:
- [FEATURES.md](FEATURES.md) - In-depth feature documentation
- [FIX_CODESIGN.md](FIX_CODESIGN.md) - Code signing troubleshooting

### Liquid Glass Design

This application implements Liquid Glass design patterns following Apple's Human Interface Guidelines:

- **Window Style**: `.automatic` - Uses native macOS window chrome
- **Toolbar API**: Native `.toolbar` with proper `ToolbarItemGroup` placement
- **Materials**: `.ultraThinMaterial`, `.thin`, and `.regular` for macOS 14-25
- **Future Ready**: Prepared for macOS 26 `.glassEffect()` and `.rect()` APIs

## Troubleshooting

### Notifications Not Working

1. Open **System Settings** > **Notifications**
2. Find "Messenger" in the list
3. Enable "Allow Notifications"

### Cannot Load messenger.com

1. Check your internet connection
2. Verify entitlements are configured correctly
3. Clear WebView cache: Delete `~/Library/Containers/com.phamhungtien.Messenger/`

### Build Errors

1. Ensure `ENABLE_USER_SCRIPT_SANDBOXING = NO` in build settings
2. Verify `CODE_SIGN_ENTITLEMENTS` is set correctly
3. Clean DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`

For detailed code signing troubleshooting, see [FIX_CODESIGN.md](FIX_CODESIGN.md).

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Roadmap

- [ ] Picture-in-Picture support for video calls
- [ ] Share Extension for sending content from other apps
- [ ] Better thread ID detection
- [ ] Custom sound notifications
- [ ] Multiple account support

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0) - see the [LICENSE](LICENSE) file for details.

For more information about GPL-3.0, visit: https://www.gnu.org/licenses/gpl-3.0.html

## Acknowledgments

- Built with native macOS technologies (SwiftUI, AppKit, WebKit)
- Inspired by the discontinued Facebook Messenger Desktop app
- Following Apple's Human Interface Guidelines

## Disclaimer

This is an unofficial, open-source project and is not affiliated with, endorsed by, or connected to Facebook/Meta. Facebook and Messenger are trademarks of Meta Platforms, Inc.

---

<p align="center">Made with ❤️ for the macOS community</p>
