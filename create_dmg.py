#!/usr/bin/env python3
"""
DMG creation script with nice appearance
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

def run_command(cmd, description=""):
    """Run a shell command and handle errors"""
    if description:
        print(f"→ {description}")
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ Error: {e.stderr}")
        return False

def create_dmg_installer():
    """Create a DMG installer with proper layout"""
    
    script_dir = Path(__file__).parent.resolve()
    build_dir = script_dir / "build"
    dmg_source = build_dir / "dmg_source"
    dmg_file = build_dir / "Messenger-1.0.dmg"
    app_path = build_dir / "Export" / "Messenger.app"
    
    print("🔨 Creating DMG Installer...\n")
    
    # Prepare DMG source folder
    if dmg_source.exists():
        shutil.rmtree(dmg_source)
    dmg_source.mkdir(parents=True, exist_ok=True)
    
    # Copy app
    if not app_path.exists():
        print("✗ Error: Messenger.app not found!")
        print(f"  Expected at: {app_path}")
        return False
    
    print(f"Copying app to DMG...")
    shutil.copytree(app_path, dmg_source / "Messenger.app", dirs_exist_ok=True)
    
    # Create Applications symlink
    print("Creating Applications shortcut...")
    os.symlink("/Applications", dmg_source / "Applications")
    
    # Create DMG
    if dmg_file.exists():
        dmg_file.unlink()
    
    print("Creating DMG image...")
    cmd = f"""hdiutil create \
        -volname "Messenger 1.0" \
        -srcfolder "{dmg_source}" \
        -ov \
        -format UDZO \
        "{dmg_file}\"""".replace('\n', ' ')
    
    if not run_command(cmd):
        return False
    
    # Get file size
    dmg_size = dmg_file.stat().st_size / (1024 * 1024)  # Convert to MB
    
    print(f"\n✓ DMG created successfully!")
    print(f"  Location: {dmg_file}")
    print(f"  Size: {dmg_size:.2f} MB\n")
    
    # Cleanup
    print("Cleaning up temporary files...")
    if dmg_source.exists():
        shutil.rmtree(dmg_source)
    
    print(f"\n✓ Build complete! Ready to release: {dmg_file}")
    return True

if __name__ == "__main__":
    success = create_dmg_installer()
    sys.exit(0 if success else 1)
