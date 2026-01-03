# Code Signing Troubleshooting Guide

This guide helps resolve code signing issues when building Messenger for macOS in Xcode.

## Table of Contents

- [Quick Fix (Recommended)](#quick-fix-recommended)
- [Method 1: Configure Signing in Xcode](#method-1-configure-signing-in-xcode)
- [Method 2: Reset Certificates](#method-2-reset-certificates)
- [Method 3: Clear Derived Data](#method-3-clear-derived-data)
- [Method 4: Modify Build Settings](#method-4-modify-build-settings)
- [After Successful Build](#after-successful-build)

---

## Quick Fix (Recommended)

The following steps resolve most code signing issues:

### Steps Already Applied

1. ✅ Removed extended attributes: `xattr -cr /path/to/Messenger/`
2. ✅ Cleared old DerivedData
3. ✅ Removed conflicting `CODE_SIGN_IDENTITY = "-"` setting
4. ✅ Set `CODE_SIGN_STYLE = Automatic` (allows Xcode to auto-select certificate)
5. ✅ Set `REGISTER_APP_GROUPS = NO` for Debug configuration
6. ✅ Kept `Messenger.icon` file in project (required for code signing)

### Next Steps in Xcode

1. **Restart your Mac** (most common solution from Apple Developer Forums)

2. **Clean Build Folder** (`Cmd+Shift+K`)

3. **Build** (`Cmd+B`)

**If errors persist**: Xcode will prompt you to select or create a certificate. Choose **"Sign to Run Locally"** when prompted.

---

## Method 1: Configure Signing in Xcode

Follow these steps to manually configure code signing:

1. **Open Xcode** → Click on **Messenger project** (at the top of the file navigator)

2. **Select Messenger target** (under TARGETS section)

3. **Navigate to "Signing & Capabilities" tab**

4. **Uncheck "Automatically manage signing"**

5. **Configure the following:**
   - **Signing Certificate**: Sign to Run Locally
   - **Provisioning Profile**: None

6. **Clean Build Folder:**
   - Menu: Product → Clean Build Folder
   - Or press `Cmd+Shift+K`

7. **Build:**
   - Menu: Product → Build
   - Or press `Cmd+B`

---

## Method 2: Reset Certificates

If Method 1 doesn't resolve the issue, try resetting your certificates:

1. **Open Xcode Preferences** (`Cmd+,`)

2. **Navigate to "Accounts" tab**

3. If you have an Apple ID configured:
   - Click **Manage Certificates**
   - Remove any old or expired certificates

4. **Return to project** → **Signing & Capabilities**:
   - **Team**: None
   - **Signing Certificate**: - (dash/empty)

5. **Clean and rebuild** the project

---

## Method 3: Clear Derived Data

Clearing Xcode's Derived Data often resolves persistent build issues:

1. **Xcode → File → Project Settings**

2. Click the **Derived Data** path (shown in blue)

3. **Finder will open** → Delete the **Messenger** folder

4. **Return to Xcode**:
   - **Clean Build Folder** (`Cmd+Shift+K`)
   - **Build** (`Cmd+B`)

**Alternative method via Terminal:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Messenger-*
```

---

## Method 4: Modify Build Settings

Manually configure build settings to disable code signing for local development:

1. **Select Project** → **Messenger target** → **Build Settings tab**

2. **Search for "Code Signing Identity"** (use filter box: "signing")

3. **For the Debug row** → Set value to: **Don't Code Sign** (or leave empty)

4. **Search for "Development Team"** → Set to: **None**

5. **Search for "Code Sign Style"** → Set to: **Automatic**

6. **Clean Build Folder** (`Cmd+Shift+K`) and **Build** (`Cmd+B`)

### Additional Build Settings to Verify

Ensure these settings are configured correctly:

| Setting | Value |
|---------|-------|
| `ENABLE_USER_SCRIPT_SANDBOXING` | NO |
| `CODE_SIGN_ENTITLEMENTS` | Messenger/Messenger.entitlements |
| `CODE_SIGN_STYLE` | Automatic |
| `REGISTER_APP_GROUPS` | NO (for Debug) |

---

## After Successful Build

Once the build succeeds, you'll find the application at:

```
~/Library/Developer/Xcode/DerivedData/Messenger-[hash]/Build/Products/Debug/Messenger.app
```

### Running the Application

**From Xcode:**
- Menu: Product → Run
- Or press `Cmd+R`

**From Finder:**
- Navigate to the build path above
- Double-click `Messenger.app` to launch

---

## Common Error Messages

### "errSecInternalComponent"

**Solution**: Restart Xcode and your Mac, then rebuild.

### "No signing certificate... found"

**Solution**:
1. Go to Signing & Capabilities
2. Select "Sign to Run Locally"
3. Or create a development certificate in Xcode Preferences → Accounts

### "Provisioning profile... doesn't include signing certificate"

**Solution**: Set Provisioning Profile to "None" in Signing & Capabilities

### "Command CodeSign failed with a nonzero exit code"

**Solution**:
1. Clear Derived Data (Method 3)
2. Remove extended attributes: `xattr -cr /path/to/Messenger`
3. Rebuild

---

## Still Having Issues?

If none of these methods work:

1. **Create a new Xcode project** with the same bundle identifier and compare build settings
2. **Check macOS Keychain** for duplicate or invalid certificates (Keychain Access app)
3. **Verify your macOS version** meets the minimum requirements (macOS 14.0+)
4. **Check Xcode version** (requires Xcode 15.0+)

For additional help, file an issue on the [GitHub repository](https://github.com/PhamHungTien/Messenger-macOS/issues).

---

## Developer Notes

### Why Code Signing is Required

Even for local development, macOS requires basic code signing for:
- Entitlements (notifications, network access)
- Sandboxing permissions
- Debugging with Xcode

### Best Practices

- Use **"Sign to Run Locally"** for development
- Use **proper certificates** for distribution
- Keep **entitlements minimal** to avoid signing issues
- **Version control** your `.xcodeproj` and `.entitlements` files

---

**Last Updated**: 2026-01-03
