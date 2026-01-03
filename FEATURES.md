# Native Features Implementation Guide

## 🔔 Native Notifications System

### How It Works
1. **JavaScript Interception**: WebView intercepts `window.Notification` API calls from messenger.com
2. **Message Handler**: Notifications are sent to Swift via WKScriptMessageHandler
3. **NotificationManager**: Creates native UNNotification with actions
4. **Quick Reply**: User types in notification → JavaScript injection → Message sent

### Implementation Details
```swift
// In WebView.swift
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
- **Reply**: UNTextInputNotificationAction → JavaScript execution to send message
- **Mark as Read**: Marks conversation as read (TODO: implement)
- **View**: Opens app and navigates to conversation

## 🎯 Menu Bar Mode

### Modes
1. **Dock Mode** (Default):
   - `NSApp.setActivationPolicy(.regular)`
   - Shows in Dock + Menu Bar

2. **Menu Bar Mode**:
   - `NSApp.setActivationPolicy(.accessory)`
   - Only shows in Menu Bar
   - Popover window on click

### Popover Window
- Size: 380x600 (optimal for conversations)
- ContentView: Full Messenger interface
- Event Monitor: Auto-close when clicking outside

### Badge Updates
- Menu bar icon changes from `message.fill` to `message.badge.fill`
- Badge count shown in icon when unread > 0

## ⌨️ Keyboard Shortcuts

### Global Hotkey (Carbon EventHotKey API)
```swift
// Cmd+Shift+M to toggle app
RegisterEventHotKey(
    UInt32(kVK_ANSI_M),          // M key
    UInt32(cmdKey + shiftKey),    // Modifiers
    gMyHotKeyID,
    GetApplicationEventTarget(),
    0,
    &hotKeyRef
)
```

### Navigation Shortcuts
All keyboard shortcuts execute JavaScript in WebView:

**Next/Previous Conversation:**
```javascript
const conversations = Array.from(document.querySelectorAll('[data-testid="conversation"]'));
const active = document.querySelector('[data-testid="conversation"][aria-selected="true"]');
const currentIndex = conversations.indexOf(active);
conversations[currentIndex + 1].click(); // Next
```

**Focus Search/Composer:**
```javascript
document.querySelector('[placeholder*="Search"]').focus();
document.querySelector('[contenteditable="true"]').focus();
```

### SwiftUI Commands
- Commands integrated into native macOS menu bar
- Keyboard equivalents defined with `.keyboardShortcut()`
- Grouped logically: Navigation, Quick Switch, etc.

## 🔗 JavaScript Bridge

### Communication Flow

**Swift → JavaScript:**
```swift
webView.evaluateJavaScript(script) { result, error in
    // Handle result
}
```

**JavaScript → Swift:**
```javascript
window.webkit.messageHandlers.notificationHandler.postMessage(data);
```

### Message Types
1. **showNotification**: Web notification intercepted
2. **unreadCount**: Update unread badge count
3. **executeJavaScript**: Run arbitrary script (for shortcuts)

## 🎨 Liquid Glass Design

### Future macOS 26 Support
```swift
// When macOS 26 is released, uncomment:
if #available(macOS 26.0, *) {
    self.glassEffect(.regular.tint(.blue), in: .rect(corners: .continuous(12)))
} else {
    // Current fallback
}
```

### GlassCornerStyle Enum
Ready for `.rect()` API:
- `.rounded(CGFloat)` → `RoundedRectangle(cornerRadius:style:.circular)`
- `.continuous(CGFloat)` → `RoundedRectangle(cornerRadius:style:.continuous)`
- `.circular` → `Circle()`
- `.capsule` → `Capsule()`

## 🔧 Technical Challenges & Solutions

### Challenge 1: Web Notifications Sandbox
**Problem**: macOS sandbox blocks web notifications
**Solution**: Intercept and replace with native notifications

### Challenge 2: Quick Reply Message Sending
**Problem**: Need to send message from notification without opening app
**Solution**: JavaScript injection to fill composer and click send button

### Challenge 3: Global Hotkey in Sandbox
**Problem**: Carbon EventHotKey API requires entitlements
**Solution**: Added `cs.allow-jit` and `cs.allow-unsigned-executable-memory`

### Challenge 4: Menu Bar Popover
**Problem**: SwiftUI WindowGroup doesn't support popover
**Solution**: NSPopover with NSHostingController(rootView: ContentView())

## 📝 Future Improvements

### Picture-in-Picture (Not Implemented Yet)
```swift
// TODO: Detect video calls and extract video element
// Use AVPictureInPictureController
let pipController = AVPictureInPictureController(playerLayer: videoLayer)
pipController.startPictureInPicture()
```

### Share Extension (Not Implemented Yet)
- Create Share Extension target in Xcode
- Handle NSExtensionItem from other apps
- Deep link into Messenger conversation

### Better Thread ID Detection
Currently using UUID fallback. Could improve by:
1. Parsing Messenger's URL structure
2. Reading from localStorage/sessionStorage
3. Monitoring network requests for thread IDs

## 🎯 Best Practices

1. **Memory Management**: Use `weak var webView` to avoid retain cycles
2. **Thread Safety**: Always dispatch UI updates to main queue
3. **Error Handling**: Log JavaScript errors for debugging
4. **Accessibility**: Provide labels and help text for all buttons
5. **Privacy**: Never log message content, only metadata

## 📚 References

- [WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter)
- [Carbon Event Manager](https://developer.apple.com/documentation/carbon/event_manager)
- [NSPopover](https://developer.apple.com/documentation/appkit/nspopover)
- [Liquid Glass Design](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass)
