# Quick Start

Quick guide to install, build, and release Messenger.

## 📥 Installation

### From DMG (Easiest)

```bash
# Download from GitHub Releases
# Open DMG → Drag Messenger to Applications
```

### From Source Code

```bash
git clone https://github.com/PhamHungTien/Messenger-macOS.git
cd Messenger
open Messenger.xcodeproj
# Build: Cmd+B, Run: Cmd+R
```

## 🔨 Development

```bash
# Open project
open Messenger.xcodeproj

# Build
xcodebuild -scheme Messenger -configuration Debug

# Test
xcodebuild test -scheme Messenger
```

## 📦 Build DMG

```bash
# Automatic (Python script)
python3 create_dmg.py

# Manual (Shell script)
./build_dmg.sh

# Result: build/Messenger-1.0.dmg
```

## 🚀 Create Release

```bash
# Tag version
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# GitHub Actions will auto-build & create release
# Or use convenience script:
chmod +x release.sh
./release.sh v1.0.0
```

## 📋 File Structure

```
Messenger/
├── Messenger/              # App source code
├── build_dmg.sh           # DMG builder (shell)
├── create_dmg.py          # DMG builder (Python)
├── release.sh             # Release automation
├── .github/workflows/     # GitHub Actions
├── README.md              # Main documentation
├── INSTALL.md             # Detailed installation
├── CHANGELOG.md           # Version history
├── RELEASE_NOTES.md       # Release guide
└── LICENSE                # GPL-3.0
```

## 🎯 Common Tasks

### Build and Test Locally
```bash
xcodebuild -scheme Messenger build
```

### Create DMG for Testing
```bash
python3 create_dmg.py
# Find at: build/Messenger-1.0.dmg
```

### Prepare Release
```bash
# Update version in Xcode
# Update CHANGELOG.md
git add .
git commit -m "Release prep: v1.0.0"
./release.sh v1.0.0
```

### Check Build Status
- Go to: https://github.com/PhamHungTien/Messenger-macOS/actions
- Click on latest workflow run

## 📚 Full Documentation

- [README.md](README.md) - Main documentation
- [INSTALL.md](INSTALL.md) - Detailed installation guide
- [RELEASE_NOTES.md](RELEASE_NOTES.md) - Release process
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contributing guide

## ❓ Need Help?

- Check [GitHub Issues](https://github.com/PhamHungTien/Messenger-macOS/issues)
- See [GitHub Discussions](https://github.com/PhamHungTien/Messenger-macOS/discussions)
- Read [FIX_CODESIGN.md](FIX_CODESIGN.md) for code signing issues

---

**Version:** 1.0.0  
**License:** GPL-3.0  
**Last Updated:** 2026-01-03
