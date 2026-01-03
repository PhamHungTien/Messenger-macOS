//
//  AppDelegate.swift
//  Messenger
//
//  Created by Phạm Hùng Tiến on 3/1/26.
//

import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup notification manager
        _ = NotificationManager.shared

        // Setup keyboard shortcuts manager
        _ = KeyboardShortcutsManager.shared

        // Setup menu bar manager
        menuBarManager = MenuBarManager()

        // Set initial activation policy
        menuBarManager.updateActivationPolicy()

        // Listen for unread count changes to update menu bar badge
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenuBarBadge(_:)),
            name: .unreadCountChanged,
            object: nil
        )
    }

    @objc private func updateMenuBarBadge(_ notification: Notification) {
        if let count = notification.userInfo?["count"] as? Int {
            menuBarManager.updateBadge(count: count)
        }
    }

    @objc func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showWindow()
        }
        return true
    }
}

extension Notification.Name {
    static let unreadCountChanged = Notification.Name("unreadCountChanged")
}
