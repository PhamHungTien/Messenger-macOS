#!/bin/bash

# Quick Release Script for Messenger
# Usage: ./release.sh v1.0.0

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "❌ Usage: $0 <version>"
    echo "   Example: $0 v1.0.0"
    exit 1
fi

# Validate version format
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format. Expected: v1.0.0"
    exit 1
fi

echo "🚀 Preparing release for version: $VERSION"

# Check if git is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Git working directory is not clean. Please commit all changes."
    exit 1
fi

# Check if tag already exists
if git rev-parse "$VERSION" >/dev/null 2>&1; then
    echo "❌ Tag $VERSION already exists!"
    exit 1
fi

echo "✓ Creating git tag..."
git tag -a "$VERSION" -m "Release version $VERSION"

echo "✓ Pushing tag to GitHub..."
git push origin "$VERSION"

echo ""
echo "✅ Release preparation complete!"
echo ""
echo "📝 Next steps:"
echo "   1. GitHub Actions will automatically build and create release"
echo "   2. Check 'Actions' tab on GitHub to monitor build progress"
echo "   3. Release will appear in 'Releases' tab when complete"
echo ""
echo "🔗 Monitor at: https://github.com/PhamHungTien/Messenger-macOS/actions"
