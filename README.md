# Messenger for macOS

Ứng dụng **Native macOS Messenger** thay thế cho Facebook Messenger Desktop đã bị khai tử. Không chỉ là WebView wrapper, đây là một ứng dụng macOS hoàn chỉnh với native notifications, menu bar mode, và keyboard shortcuts nâng cao.

## ✨ Tính năng Native macOS

### 🔔 Native Notifications với Quick Reply
- **Intercept Web Notifications**: Chặn web notifications và hiển thị native macOS notifications
- **Quick Reply**: Reply ngay từ notification banner không cần mở app
- **Action Buttons**: Reply, Mark as Read, View actions
- **Rich Notifications**: Hiển thị avatar, preview tin nhắn
- **Always On Top**: Notifications hiện ngay cả khi app đang ở foreground

### 🎯 Menu Bar Mode
- **Menu Bar Only**: Chạy app ở menu bar, không cần dock icon
- **Popover Window**: Click menu bar icon để mở popover 380x600
- **Quick Access**: Right-click để mở menu với settings
- **Badge Icon**: Icon thay đổi khi có tin nhắn chưa đọc
- **Toggle Mode**: Switch giữa dock mode và menu bar mode

### ⌨️ Keyboard Shortcuts Nâng Cao
**Global Hotkey:**
- `Cmd+Shift+M`: Show/Hide app từ bất kỳ đâu

**Navigation:**
- `Cmd+Opt+↓`: Next conversation
- `Cmd+Opt+↑`: Previous conversation
- `Cmd+F`: Focus search
- `Cmd+K`: Focus message composer

**Quick Switch:**
- `Cmd+1` through `Cmd+5`: Switch to conversation 1-5

**Standard:**
- `Cmd+N`: New message
- `Cmd+C/V/X/A`: Copy/Paste/Cut/Select All

### 🎨 Modern Design
- **Hidden Title Bar**: Immersive full-screen experience, không có title bar thừa
- **Edge-to-Edge WebView**: WebView toàn màn hình, Messenger.com tự quản lý UI
- **Minimal Chrome**: Chỉ traffic light buttons, không duplicate với Messenger's UI
- **Liquid Glass Ready**: Sẵn sàng cho macOS 26 Liquid Glass API
- **Dark Mode**: Tự động theo system appearance

## Yêu cầu

- macOS 14.0 trở lên
- Xcode 15.0 trở lên (để build)

## Cách build và chạy

1. Mở `Messenger.xcodeproj` trong Xcode
2. Đảm bảo tất cả các file đã được thêm vào project:
   - `MessengerApp.swift`
   - `ContentView.swift`
   - `WebView.swift`
   - `AppDelegate.swift`
   - `Messenger.entitlements`
3. Chọn target "Messenger" và nhấn `Cmd+R` để build và chạy
4. Lần đầu tiên chạy, ứng dụng sẽ yêu cầu quyền notifications - hãy cho phép

## 🏗️ Architecture

### Design Philosophy
**Minimal Native Chrome, Maximum Web Fidelity**
- Messenger.com đã có UI hoàn chỉnh với sidebar, search, navigation
- App chỉ cần cung cấp native container và services (notifications, shortcuts)
- Không duplicate UI elements → Clean, immersive experience

### File Structure
```
Messenger/
├── MessengerApp.swift             # Main app, hidden title bar window
├── ContentView.swift              # Full-screen WebView, edge-to-edge
├── AppDelegate.swift              # App lifecycle, menu bar integration
│
├── WebView.swift                  # WKWebView với JavaScript bridge
│   ├── Notification interception (web → native)
│   ├── Unread count tracking
│   └── Quick reply injection (native → web)
│
├── NotificationManager.swift      # Native macOS notifications
│   ├── UNUserNotificationCenter delegate
│   ├── Quick reply text input actions
│   └── Rich notifications with avatars
│
├── MenuBarManager.swift           # Menu bar mode
│   ├── NSStatusItem management
│   ├── Popover window (380x600)
│   └── Event monitor for auto-close
│
├── KeyboardShortcutsManager.swift # Advanced shortcuts
│   ├── Carbon EventHotKey for global Cmd+Shift+M
│   ├── Navigation (Cmd+Opt+↓/↑, Cmd+1-5)
│   └── Focus management (Cmd+F, Cmd+K)
│
├── LiquidGlassModifiers.swift     # Optional glass effects
├── GlassToolbar.swift             # Reference component (unused)
├── Messenger.entitlements         # Sandbox permissions
└── Assets.xcassets/               # App icons
```

## 🚀 Cách sử dụng

### Build và Run
```bash
open Messenger.xcodeproj
# Cmd+R để build và run
```

### Lần đầu sử dụng
1. **Grant Notification Permission**: App sẽ xin quyền notifications - nhấn "Allow"
2. **Login to Messenger**: Đăng nhập Facebook/Messenger trong WebView
3. **Try Quick Reply**: Khi có tin nhắn mới, reply ngay từ notification
4. **Global Hotkey**: Nhấn `Cmd+Shift+M` để show/hide app

### Menu Bar Mode
1. Right-click menu bar icon → "Menu Bar Mode"
2. App sẽ ẩn khỏi Dock, chỉ hiện ở menu bar
3. Click icon để mở popover window
4. Toggle lại để trở về Dock mode

## Liquid Glass Design Implementation

Ứng dụng này sử dụng Liquid Glass design patterns theo Apple Human Interface Guidelines:

### Native macOS Design
- **Window Style**: `.automatic` - Sử dụng native macOS window chrome với title bar
- **Toolbar API**: Native `.toolbar` với `ToolbarItemGroup` placement
- **Toolbar Items**:
  - `.navigation` placement: Search button ở leading edge
  - `.primaryAction` placement: New Message button và unread badge ở trailing edge
- **Accessibility**: Label và help text cho tất cả toolbar items

### Liquid Glass API Compatibility
- **macOS 14-25**: Sử dụng `.ultraThinMaterial`, `.thin`, và `.regular` materials
- **macOS 26+**: Sẵn sàng cho `.glassEffect()` và `.rect()` API
  - `GlassCornerStyle` enum hỗ trợ `.rounded()`, `.continuous()`, `.circular`, `.capsule`
  - Tương thích với `ConcentricRectangle.rect(corners:isUniform:)`

### Custom Modifiers (Optional)
- `.liquidGlass(tint:intensity:cornerStyle:)`: Glass effect với corner styles
- `.interactiveGlass(tint:)`: Interactive button với hover và scale animation
- `LiquidGlassIntensity`: `.clear`, `.regular`, `.thick`

### Best Practices
- ✅ Sử dụng native SwiftUI controls và modifiers
- ✅ Follow Apple HIG cho window và toolbar design
- ✅ Keyboard shortcuts integrated vào Command menu
- ✅ Proper accessibility labels và help text

## Troubleshooting

### Nếu notifications không hoạt động

1. Mở **System Settings** > **Notifications**
2. Tìm "Messenger" trong danh sách
3. Bật "Allow Notifications"

### Nếu không load được messenger.com

1. Kiểm tra kết nối internet
2. Đảm bảo entitlements đã được cấu hình đúng
3. Thử xóa cache của WebView: Xóa `~/Library/Containers/com.phamhungtien.Messenger/`

### Nếu không build được

1. Đảm bảo ENABLE_USER_SCRIPT_SANDBOXING = NO trong build settings
2. Đảm bảo CODE_SIGN_ENTITLEMENTS đã được set đúng
3. Xóa DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`

## License

MIT License - Free to use and modify
