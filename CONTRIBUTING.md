# Contributing to Messenger for macOS

Thank you for your interest in contributing to Messenger for macOS! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of background or identity.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, trolling, or discriminatory comments
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **macOS 14.0+** installed
- **Xcode 15.0+** installed
- Basic knowledge of **Swift** and **SwiftUI**
- Familiarity with **Git** and **GitHub**

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Messenger-macOS.git
   cd Messenger-macOS
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/PhamHungTien/Messenger-macOS.git
   ```

---

## Development Setup

1. **Open the project** in Xcode:
   ```bash
   open Messenger.xcodeproj
   ```

2. **Configure code signing** (see [FIX_CODESIGN.md](FIX_CODESIGN.md)):
   - Go to Signing & Capabilities
   - Select "Sign to Run Locally"

3. **Build the project** (`Cmd+B`) to ensure everything works

4. **Run the app** (`Cmd+R`) to test functionality

---

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **Bug fixes**: Resolve issues or unexpected behavior
- **New features**: Implement items from the [Roadmap](README.md#roadmap)
- **Documentation**: Improve README, guides, or code comments
- **UI/UX improvements**: Enhance user interface and experience
- **Performance optimizations**: Make the app faster or more efficient
- **Tests**: Add unit tests or integration tests

### Before You Start

1. **Check existing issues** to avoid duplicate work
2. **Create an issue** to discuss major changes before implementing
3. **Ask questions** if anything is unclear

---

## Coding Standards

### Swift Style Guide

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

- Use **clear, descriptive names** for variables and functions
- Prefer **clarity over brevity**
- Use **camelCase** for variables and functions
- Use **PascalCase** for types and protocols

### Code Organization

```swift
// MARK: - Properties
private var myVariable: String

// MARK: - Lifecycle
override func viewDidLoad() {
    super.viewDidLoad()
}

// MARK: - Public Methods
func publicMethod() {
}

// MARK: - Private Methods
private func privateHelper() {
}
```

### SwiftUI Best Practices

- **Extract reusable views** into separate files
- Use **@StateObject** for owned objects, **@ObservedObject** for passed objects
- Prefer **environment objects** for shared state
- Keep views **small and focused**

### Documentation

Add documentation comments for public APIs:

```swift
/// Brief description of the function
///
/// - Parameters:
///   - parameter1: Description of parameter1
///   - parameter2: Description of parameter2
/// - Returns: Description of return value
func myFunction(parameter1: String, parameter2: Int) -> Bool {
    // Implementation
}
```

---

## Commit Guidelines

### Commit Message Format

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Build process, dependencies, etc.

### Examples

```
feat(notifications): add sound support for notifications

Implements custom notification sounds that can be configured
in the app preferences.

Closes #42
```

```
fix(webview): resolve crash when loading messenger.com

Fixed a race condition in WebView initialization that caused
crashes on slower connections.

Fixes #38
```

### Best Practices

- **Use the imperative mood** ("add feature" not "added feature")
- **Keep subject line under 50 characters**
- **Separate subject from body** with a blank line
- **Wrap body at 72 characters**
- **Reference issues and PRs** in the footer

---

## Pull Request Process

### Before Submitting

1. **Update from upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests** (if available) and ensure they pass

3. **Test your changes** thoroughly

4. **Update documentation** if you changed functionality

### Submitting a Pull Request

1. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request** on GitHub:
   - Use a clear, descriptive title
   - Reference related issues (e.g., "Closes #42")
   - Describe what changed and why
   - Include screenshots for UI changes

3. **Address review feedback** promptly

4. **Keep your PR updated** with the main branch if needed

### PR Title Format

Use the same format as commit messages:

```
feat(notifications): add sound support
```

---

## Reporting Bugs

### Before Reporting

1. **Check existing issues** to avoid duplicates
2. **Test with the latest version** from the main branch
3. **Verify it's not a configuration issue** (see [Troubleshooting](README.md#troubleshooting))

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- macOS version: [e.g., 14.2]
- Xcode version: [e.g., 15.1]
- App version/commit: [e.g., commit hash]

**Additional context**
Any other relevant information.
```

---

## Suggesting Features

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Other solutions you've thought about.

**Additional context**
Any other relevant information, mockups, or examples.
```

### Feature Discussion

- Open an issue **before implementing** major features
- Be open to feedback and alternative approaches
- Consider backward compatibility and existing users

---

## Development Guidelines

### Testing

- **Manual testing**: Test your changes thoroughly before submitting
- **Edge cases**: Consider error conditions and edge cases
- **Performance**: Ensure changes don't negatively impact performance

### Privacy and Security

- **Never log sensitive data** (message content, user credentials)
- **Follow Apple's App Sandbox guidelines**
- **Minimize permissions** in entitlements
- **Review security implications** of web-native bridges

### Accessibility

- Provide **meaningful labels** for UI elements
- Support **keyboard navigation**
- Test with **VoiceOver** when modifying UI

---

## Questions or Need Help?

- **Open an issue** for questions about contributing
- **Check existing documentation** in README.md and FEATURES.md
- **Be patient and respectful** when asking for help

---

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes for significant contributions
- Special thanks in the README (for major contributions)

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

Thank you for contributing to Messenger for macOS!
