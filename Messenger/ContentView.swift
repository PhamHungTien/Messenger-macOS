//
//  ContentView.swift
//  Messenger
//
//  Created by Phạm Hùng Tiến on 3/1/26.
//

import SwiftUI
import UserNotifications
import AppKit

struct ContentView: View {
    @State private var unreadCount: Int = 0

    var body: some View {
        ZStack {
            // Fullscreen WebView
            WebView(
                url: URL(string: "https://www.messenger.com")!,
                unreadCount: $unreadCount
            )
            .frame(minWidth: 800, minHeight: 600)

            // NSView overlay for window dragging
            // Only intercepts top 44px, rest passes through to WebView
            DraggableWindowView()
        }
        // Let SwiftUI/macOS handle corner radius automatically
        // macOS 26 Liquid Glass will apply proper corner radius
        .ignoresSafeArea()
        .onAppear {
            requestNotificationPermission()
            configureWindow()
        }
    }

    private func configureWindow() {
        // Configure window for macOS 26 Liquid Glass design
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                window.isMovableByWindowBackground = true

                // macOS 26 Tahoe: Let system apply Liquid Glass corner radius
                // Window corners are automatically rounded by macOS 26
                if #available(macOS 26.0, *) {
                    // Liquid Glass design handles corners automatically
                    // Radius varies by context (concentric curves)
                    window.contentView?.wantsLayer = true
                    window.contentView?.layer?.masksToBounds = true
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
