//
//  MenuBarManager.swift
//  Messenger
//
//  Manages menu bar mode with popover window
//

import AppKit
import SwiftUI

class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: EventMonitor?

    @AppStorage("menuBarMode") private var menuBarMode = false

    override init() {
        super.init()
        setupStatusItem()
        setupPopover()
        setupEventMonitor()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Use custom menu bar icon
            if let menuBarIcon = NSImage(named: "Messenger_menubar") {
                // Resize to menu bar size (18x18 for Retina)
                menuBarIcon.size = NSSize(width: 18, height: 18)
                menuBarIcon.isTemplate = true // Adapt to dark/light menu bar
                button.image = menuBarIcon
            } else {
                // Fallback to SF Symbol
                button.image = NSImage(systemSymbolName: "message.fill", accessibilityDescription: "Messenger")
            }
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 380, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }

    private func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let self = self, self.popover.isShown {
                self.closePopover()
            }
        }
    }

    @objc func togglePopover() {
        guard let button = statusItem.button else { return }

        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showMenu()
            return
        }

        if popover.isShown {
            closePopover()
        } else {
            showPopover(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func showPopover(relativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge) {
        popover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
        eventMonitor?.start()
    }

    func closePopover() {
        popover.performClose(nil)
        eventMonitor?.stop()
    }

    private func showMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Show Messenger", action: #selector(showMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let menuBarModeItem = NSMenuItem(
            title: "Menu Bar Mode",
            action: #selector(toggleMenuBarMode),
            keyEquivalent: ""
        )
        menuBarModeItem.state = menuBarMode ? .on : .off
        menu.addItem(menuBarModeItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Messenger", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.isVisible }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    @objc private func toggleMenuBarMode() {
        menuBarMode.toggle()
        updateActivationPolicy()
    }

    @objc private func showPreferences() {
        showMainWindow()
        // TODO: Open preferences window
    }

    func updateActivationPolicy() {
        if menuBarMode {
            NSApp.setActivationPolicy(.accessory)
            // Hide all windows when switching to menu bar mode
            NSApp.hide(nil)
        } else {
            NSApp.setActivationPolicy(.regular)
            showMainWindow()
        }
    }

    func updateBadge(count: Int) {
        if let button = statusItem.button {
            // Use custom menu bar icon with badge overlay
            if let menuBarIcon = NSImage(named: "Messenger_menubar") {
                menuBarIcon.size = NSSize(width: 18, height: 18)
                menuBarIcon.isTemplate = true

                if count > 0 {
                    // Create badge overlay
                    let badgedIcon = createBadgedIcon(baseIcon: menuBarIcon, count: count)
                    button.image = badgedIcon
                } else {
                    button.image = menuBarIcon
                }
            } else {
                // Fallback to SF Symbol
                if count > 0 {
                    button.image = NSImage(systemSymbolName: "message.badge.fill", accessibilityDescription: "Messenger (\(count) unread)")
                } else {
                    button.image = NSImage(systemSymbolName: "message.fill", accessibilityDescription: "Messenger")
                }
            }
        }
    }

    private func createBadgedIcon(baseIcon: NSImage, count: Int) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let badgedIcon = NSImage(size: size)

        badgedIcon.lockFocus()

        // Draw base icon
        baseIcon.draw(in: NSRect(origin: .zero, size: size))

        // Draw red badge circle
        let badgeSize: CGFloat = 8
        let badgeRect = NSRect(x: size.width - badgeSize - 1, y: size.height - badgeSize - 1, width: badgeSize, height: badgeSize)

        NSColor.systemRed.setFill()
        let badgePath = NSBezierPath(ovalIn: badgeRect)
        badgePath.fill()

        badgedIcon.unlockFocus()
        badgedIcon.isTemplate = true // Make it adapt to dark/light mode

        return badgedIcon
    }
}

// MARK: - Event Monitor

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
