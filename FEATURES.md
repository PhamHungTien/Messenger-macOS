# Feature Implementation Guide

This document provides detailed technical documentation for the native macOS features implemented in Messenger for macOS.

## Table of Contents

- [Native Notifications System](#-native-notifications-system)
- [Menu Bar Mode](#-menu-bar-mode)
- [Keyboard Shortcuts](#️-keyboard-shortcuts)
- [JavaScript Bridge](#-javascript-bridge)
- [Liquid Glass Design](#-liquid-glass-design)
- [Technical Challenges & Solutions](#-technical-challenges--solutions)
- [Future Improvements](#-future-improvements)
- [Best Practices](#-best-practices)
- [References](#-references)

---

## 🔔 Native Notifications System

### Overview

The notification system intercepts web notifications from messenger.com and converts them into native macOS notifications with rich features including Quick Reply functionality.

### How It Works

1. **JavaScript Interception**: The WebView intercepts `window.Notification` API calls from messenger.com
2. **Message Handler**: Notifications are forwarded to Swift via `WKScriptMessageHandler`
3. **NotificationManager**: Creates native `UNNotification` instances with custom actions
4. **Quick Reply**: User input from notification banner triggers JavaScript injection to send the message

### Implementation Details

**WebView Notification Interception** (`WebView.swift`):

```swift
window.Notification = function(title, options) {
    window.webkit.messageHandlers.notificationHandler.postMessage({
        type: 'showNotification',
        title: title,
        body: options?.body || '',
        icon: options?.icon || ''
    });
    return { close: function() {} };
};
```

### Notification Actions

- **Reply**: `UNTextInputNotificationAction` triggers JavaScript execution to send the message
- **Mark as Read**: Marks the conversation as read (planned feature)
- **View**: Opens the app and navigates to the conversation

---

## 🎯 Menu Bar Mode

### Overview

Provides two operational modes: traditional Dock mode and a lightweight Menu Bar-only mode with popover interface.

### Modes

**1. Dock Mode (Default)**
- Activation: `NSApp.setActivationPolicy(.regular)`
- Visibility: Shows in both Dock and Menu Bar
- Behavior: Standard macOS application window

**2. Menu Bar Mode**
- Activation: `NSApp.setActivationPolicy(.accessory)`
- Visibility: Menu Bar only
- Behavior: Popover window on icon click

### Popover Window Configuration

- **Size**: 380×600 pixels (optimized for conversation views)
- **Content**: Full Messenger interface via `ContentView`
- **Auto-close**: Event monitor detects outside clicks

### Badge Updates

- Icon switches from `message.fill` to `message.badge.fill` when unread messages exist
- Badge count displayed when unread count > 0

---

## ⌨️ Keyboard Shortcuts

### Global Hotkey Implementation

Uses the Carbon Event Manager API for system-wide hotkey registration:

```swift
// Register Cmd+Shift+M to toggle app visibility
RegisterEventHotKey(
    UInt32(kVK_ANSI_M),          // M key virtual keycode
    UInt32(cmdKey + shiftKey),    // Command + Shift modifiers
    gMyHotKeyID,
    GetApplicationEventTarget(),
    0,
    &hotKeyRef
)
```

### Navigation Shortcuts via JavaScript

All navigation shortcuts execute JavaScript in the WebView:

**Next/Previous Conversation:**
```javascript
const conversations = Array.from(document.querySelectorAll('[data-testid="conversation"]'));
const active = document.querySelector('[data-testid="conversation"][aria-selected="true"]');
const currentIndex = conversations.indexOf(active);
conversations[currentIndex + 1].click(); // Navigate to next conversation
```

**Focus Search/Composer:**
```javascript
document.querySelector('[placeholder*="Search"]').focus();
document.querySelector('[contenteditable="true"]').focus();
```

### SwiftUI Commands Integration

- Commands integrated into native macOS menu bar
- Keyboard equivalents defined using `.keyboardShortcut()` modifier
- Logically grouped: Navigation, Quick Switch, Actions

---

## 🔗 JavaScript Bridge

### Communication Architecture

**Swift → JavaScript:**
```swift
webView.evaluateJavaScript(script) { result, error in
    if let error = error {
        print("JavaScript error: \(error)")
    }
    // Handle result
}
```

**JavaScript → Swift:**
```javascript
window.webkit.messageHandlers.notificationHandler.postMessage({
    type: 'messageType',
    data: payload
});
```

### Message Types

1. **showNotification**: Web notification intercepted and converted to native
2. **unreadCount**: Updates badge count in menu bar
3. **executeJavaScript**: Executes arbitrary scripts (used for keyboard shortcuts)

---

## 🎨 Liquid Glass Design

### macOS 26 Compatibility

Prepared for future macOS 26 Liquid Glass APIs:

```swift
if #available(macOS 26.0, *) {
    self.glassEffect(.regular.tint(.blue), in: .rect(corners: .continuous(12)))
} else {
    // Fallback to current materials
    self.background(.ultraThinMaterial)
}
```

### GlassCornerStyle Enum

Ready for `.rect()` API with multiple corner styles:
- `.rounded(CGFloat)` → `RoundedRectangle(cornerRadius:style:.circular)`
- `.continuous(CGFloat)` → `RoundedRectangle(cornerRadius:style:.continuous)`
- `.circular` → `Circle()`
- `.capsule` → `Capsule()`

---

## 🔧 Technical Challenges & Solutions

### Challenge 1: Web Notifications in Sandbox

**Problem**: macOS App Sandbox blocks web notifications from displaying
**Solution**: Intercept web notification API and replace with native macOS notifications

### Challenge 2: Quick Reply Without App Activation

**Problem**: Need to send messages from notification banner without opening the app
**Solution**: JavaScript injection fills the composer field and programmatically triggers send

### Challenge 3: Global Hotkey in Sandboxed Environment

**Problem**: Carbon EventHotKey API requires special entitlements
**Solution**: Added `com.apple.security.cs.allow-jit` and related entitlements

### Challenge 4: SwiftUI Popover Limitations

**Problem**: SwiftUI `WindowGroup` doesn't natively support popover presentation
**Solution**: Use `NSPopover` with `NSHostingController(rootView: ContentView())`

---

## 📝 Future Improvements

### Picture-in-Picture Mode

**Status**: Not yet implemented

```swift
// TODO: Detect video call elements and implement PiP
import AVKit

let pipController = AVPictureInPictureController(playerLayer: videoLayer)
pipController.startPictureInPicture()
```

**Implementation Plan**:
1. Detect video call initiation
2. Extract video element from WebView
3. Create AVPlayerLayer
4. Enable PiP controller

### Share Extension

**Status**: Not yet implemented

**Implementation Plan**:
1. Create Share Extension target in Xcode
2. Handle `NSExtensionItem` from sharing apps
3. Deep link into specific Messenger conversation
4. Pre-fill composer with shared content

### Enhanced Thread ID Detection

**Current State**: Uses UUID fallback for thread identification

**Improvement Strategies**:
1. Parse Messenger's URL structure for thread IDs
2. Access localStorage/sessionStorage for conversation data
3. Monitor network requests to extract thread metadata
4. Implement conversation selection state tracking

---

## 🎯 Best Practices

### 1. Memory Management
- Use `weak var webView` in closures to prevent retain cycles
- Properly deallocate observers and handlers in `deinit`

### 2. Thread Safety
- Always dispatch UI updates to the main queue
- Use appropriate synchronization for shared state

### 3. Error Handling
- Log JavaScript errors for debugging
- Implement graceful fallbacks for failed operations

### 4. Accessibility
- Provide descriptive labels for all UI elements
- Include help text for toolbar items and buttons

### 5. Privacy
- Never log message content or user data
- Only track metadata necessary for functionality

### 6. Code Organization
- Keep JavaScript injection scripts in separate files when complex
- Document all bridging functions and their expected behavior

---

## 📚 References

### Official Apple Documentation

- [WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [WKScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler)
- [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter)
- [Carbon Event Manager](https://developer.apple.com/documentation/carbon/event_manager)
- [NSPopover](https://developer.apple.com/documentation/appkit/nspopover)
- [NSStatusItem](https://developer.apple.com/documentation/appkit/nsstatusitem)

### Design Guidelines

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [Liquid Glass Design Patterns](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass)

### Related Technologies

- [JavaScript in WKWebView](https://developer.apple.com/documentation/webkit/wkuserscript)
- [User Notifications Framework](https://developer.apple.com/documentation/usernotifications)
- [App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)

---

**Note**: This guide is intended for developers contributing to or learning from this project. For user-facing documentation, see [README.md](README.md).
