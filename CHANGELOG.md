# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-03

### Added
- Initial release of Messenger for macOS
- Native notifications with Quick Reply support
- Menu bar mode for quick access
- Advanced keyboard shortcuts (Cmd+Shift+M to show/hide)
- Web notification interception
- Native macOS integration with AppKit and SwiftUI
- Dark mode support
- Custom notification sounds
- Always-on-top notification windows
- Popover window (380x600) for menu bar mode
- Badge notifications for unread messages
- Rich notifications with avatars and message previews
- Action buttons (Reply, Mark as Read, View)

### Changed
- Switched license from MIT to GPL-3.0
- Project structure optimized for distribution

### Technical
- Built with SwiftUI and AppKit
- Uses WebKit for Facebook Messenger integration
- Native macOS notification system
- Global keyboard shortcut support
- Automatic app launching

---

## Semantic Versioning Format

Following [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible functionality additions
- **PATCH**: Backwards-compatible bug fixes

### Release History

- **1.0.0**: Initial public release with core features
