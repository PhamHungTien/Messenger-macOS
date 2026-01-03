//
//  MessengerApp.swift
//  Messenger
//
//  Created by Phạm Hùng Tiến on 3/1/26.
//

import SwiftUI

@main
struct MessengerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // Follow system dark mode
        }
        .windowStyle(.hiddenTitleBar) // Hidden titlebar - macOS 26 Liquid Glass
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Message") {
                    NotificationCenter.default.post(name: .newMessage, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            // Navigation commands
            CommandGroup(after: .sidebar) {
                Section("Navigation") {
                    Button("Next Conversation") {
                        KeyboardShortcutsManager.shared.nextConversation()
                    }
                    .keyboardShortcut(.downArrow, modifiers: [.command, .option])

                    Button("Previous Conversation") {
                        KeyboardShortcutsManager.shared.previousConversation()
                    }
                    .keyboardShortcut(.upArrow, modifiers: [.command, .option])

                    Button("Focus Search") {
                        KeyboardShortcutsManager.shared.focusSearch()
                    }
                    .keyboardShortcut("f", modifiers: .command)

                    Button("Focus Message") {
                        KeyboardShortcutsManager.shared.focusComposer()
                    }
                    .keyboardShortcut("k", modifiers: .command)
                }

                Section("Quick Switch") {
                    ForEach(1...5, id: \.self) { index in
                        Button("Conversation \(index)") {
                            KeyboardShortcutsManager.shared.switchToConversation(index: index - 1)
                        }
                        .keyboardShortcut(KeyEquivalent(Character(String(index))), modifiers: .command)
                    }
                }
            }

            CommandGroup(replacing: .pasteboard) {
                Button("Cut") {
                    NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("x", modifiers: .command)

                Button("Copy") {
                    NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("c", modifiers: .command)

                Button("Paste") {
                    NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("v", modifiers: .command)

                Button("Select All") {
                    NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("a", modifiers: .command)
            }
        }
        .defaultSize(width: 1000, height: 700)
    }
}

extension Notification.Name {
    static let newMessage = Notification.Name("newMessage")
}
