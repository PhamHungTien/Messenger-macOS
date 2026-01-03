//
//  KeyboardShortcutsManager.swift
//  Messenger
//
//  Advanced keyboard shortcuts with global hotkey support
//

import AppKit
import Carbon

class KeyboardShortcutsManager {
    static let shared = KeyboardShortcutsManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    private init() {
        setupGlobalHotkey()
    }

    deinit {
        unregisterGlobalHotkey()
    }

    // MARK: - Global Hotkey (Cmd+Shift+M to show/hide app)

    private func setupGlobalHotkey() {
        var gMyHotKeyID = EventHotKeyID()
        gMyHotKeyID.id = 1
        gMyHotKeyID.signature = fourCharCodeFrom("MSGR")

        var eventType = EventTypeSpec()
        eventType.eventClass = UInt32(kEventClassKeyboard)
        eventType.eventKind = UInt32(kEventHotKeyPressed)

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, inEvent, _ -> OSStatus in
                _ = KeyboardShortcutsManager.shared.handleGlobalHotkey(inEvent)
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )

        // Register Cmd+Shift+M
        RegisterEventHotKey(
            UInt32(kVK_ANSI_M),
            UInt32(cmdKey + shiftKey),
            gMyHotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private func unregisterGlobalHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    private func handleGlobalHotkey(_ event: EventRef?) -> OSStatus {
        DispatchQueue.main.async {
            if NSApp.isActive {
                NSApp.hide(nil)
            } else {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
            }
        }
        return noErr
    }

    // MARK: - Conversation Navigation

    func switchToConversation(index: Int) {
        let script = """
        (function() {
            const conversations = document.querySelectorAll('[data-testid="conversation"]');
            if (conversations[\(index)]) {
                conversations[\(index)].click();
            }
        })();
        """

        executeInWebView(script)
    }

    func nextConversation() {
        let script = """
        (function() {
            const conversations = Array.from(document.querySelectorAll('[data-testid="conversation"]'));
            const active = document.querySelector('[data-testid="conversation"][aria-selected="true"]');
            const currentIndex = conversations.indexOf(active);
            if (currentIndex >= 0 && currentIndex < conversations.length - 1) {
                conversations[currentIndex + 1].click();
            }
        })();
        """

        executeInWebView(script)
    }

    func previousConversation() {
        let script = """
        (function() {
            const conversations = Array.from(document.querySelectorAll('[data-testid="conversation"]'));
            const active = document.querySelector('[data-testid="conversation"][aria-selected="true"]');
            const currentIndex = conversations.indexOf(active);
            if (currentIndex > 0) {
                conversations[currentIndex - 1].click();
            }
        })();
        """

        executeInWebView(script)
    }

    func focusSearch() {
        let script = """
        (function() {
            const search = document.querySelector('[placeholder*="Search"]') ||
                          document.querySelector('input[type="search"]');
            if (search) {
                search.focus();
            }
        })();
        """

        executeInWebView(script)
    }

    func focusComposer() {
        let script = """
        (function() {
            const composer = document.querySelector('[contenteditable="true"]');
            if (composer) {
                composer.focus();
            }
        })();
        """

        executeInWebView(script)
    }

    // MARK: - Helper

    private func executeInWebView(_ script: String) {
        // Post notification to WebView to execute script
        NotificationCenter.default.post(
            name: .executeJavaScript,
            object: nil,
            userInfo: ["script": script]
        )
    }
}

// Helper to convert FourCharCode string to OSType
private func fourCharCodeFrom(_ string: String) -> FourCharCode {
    assert(string.count == 4, "String length must be 4")
    var result: FourCharCode = 0
    for char in string.utf16 {
        result = (result << 8) + FourCharCode(char)
    }
    return result
}

extension Notification.Name {
    static let executeJavaScript = Notification.Name("executeJavaScript")
}

// Virtual key codes
private let kVK_ANSI_M: UInt32 = 0x2E
