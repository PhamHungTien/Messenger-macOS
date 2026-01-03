# Release Notes

## How to Create Release for Messenger 1.0

### Prerequisites

- Xcode 15.0 or later
- macOS 12.0 or later
- Git repository pushed to GitHub
- GitHub CLI (optional but recommended)

### Step 1: Prepare Code

1. **Update version** (if needed)
   - Open `Messenger.xcodeproj` in Xcode
   - Target: Messenger
   - Build Settings → Search "Marketing Version"
   - Change value (e.g., 1.0.0)

2. **Update CHANGELOG.md**
   ```markdown
   ## [1.0.0] - 2026-01-03
   ### Added
   - Initial release features...
   ```

3. **Commit changes**
   ```bash
   git add .
   git commit -m "Release v1.0.0"
   git push origin main
   ```

### Step 2: Create Git Tag

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0 - Messenger for macOS"

# Push tag to GitHub
git push origin v1.0.0
```

### Step 3: Automatic Build & Release (Recommended)

GitHub Actions will automatically:
1. Detect tag `v*`
2. Build app on macOS-latest runner
3. Create DMG installer
4. Create GitHub Release
5. Upload DMG to release

**Status:** Check in the `Actions` tab on GitHub

### Step 4: Manual Build (If Needed)

If GitHub Actions isn't set up or you want to build locally:

```bash
# Run build script
chmod +x build_dmg.sh
./build_dmg.sh
```

Or use Python script:
```bash
python3 create_dmg.py
```

DMG will be created at: `build/Messenger-1.0.dmg`

### Step 5: Manual Upload (If Needed)

```bash
# If using GitHub CLI
gh release create v1.0.0 \
  --title "Messenger for macOS 1.0.0" \
  --notes "First stable release" \
  build/Messenger-1.0.dmg

# Or upload via GitHub Web UI
# 1. Go to Releases tab
# 2. Click "Create a new release"
# 3. Select tag v1.0.0
# 4. Add title and description
# 5. Drag & drop DMG file
# 6. Click "Publish release"
```

### Step 6: Verify Release

1. **Check GitHub Release Page**
   - DMG uploaded successfully
   - SHA256 checksums displayed
   - Release notes clear

2. **Test DMG**
   - Download DMG from release
   - Install on test machine
   - Verify app works normally

3. **Announce**
   - Update social media
   - Notify users if mailing list exists

---

## Release Timeline for v1.0.0

- **2026-01-03**: Initial release
  - Core features complete
  - GPL-3.0 license applied
  - DMG installer ready

---

## Semantic Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH**
  - MAJOR: Incompatible API changes
  - MINOR: Backward-compatible features
  - PATCH: Backward-compatible bug fixes

### Examples
- v1.0.0 → Initial release
- v1.1.0 → New feature (backward-compatible)
- v1.0.1 → Bug fix
- v2.0.0 → Breaking changes

---

## Pre-Release Checklist

- [ ] Code review complete
- [ ] All tests passed
- [ ] CHANGELOG.md updated
- [ ] README.md updated
- [ ] INSTALL.md updated
- [ ] Version number updated
- [ ] Build test successful
- [ ] DMG installer test successful
- [ ] GitHub tag created
- [ ] Release notes written
- [ ] Code signing certificates valid

---

## Troubleshooting

### Build Failed

```bash
# Clean everything
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData

# Try again
./build_dmg.sh
```

### Code Signing Issues

```bash
# Check certificates
security find-identity -v -p codesigning

# See FIX_CODESIGN.md for details
```

### DMG Creation Failed

- Ensure `hdiutil` is available (included with macOS)
- Check disk space
- Review error messages in output

### GitHub Actions Failed

1. Check logs in Actions tab
2. Verify ExportOptions.plist syntax
3. Validate workflow file YAML

---

## Support

- Issues: [GitHub Issues](../../issues)
- Discussions: [GitHub Discussions](../../discussions)

---

**Last Updated:** 2026-01-03
**Current Version:** 1.0.0
**License:** GPL-3.0
