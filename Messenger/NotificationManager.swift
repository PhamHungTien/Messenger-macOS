//
//  NotificationManager.swift
//  Messenger
//
//  Native macOS notifications with quick reply support
//

import Foundation
import UserNotifications
import AppKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        setupNotifications()
    }

    func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        // Request authorization with all options
        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            if granted {
                print("Notification permission granted")
                self.registerNotificationCategories()
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func registerNotificationCategories() {
        // Quick Reply action
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_ACTION",
            title: "Reply",
            options: [.authenticationRequired],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type a message..."
        )

        // Mark as Read action
        let markReadAction = UNNotificationAction(
            identifier: "MARK_READ_ACTION",
            title: "Mark as Read",
            options: [.authenticationRequired]
        )

        // View action
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View",
            options: [.foreground]
        )

        // Message category with actions
        let messageCategory = UNNotificationCategory(
            identifier: "MESSAGE_CATEGORY",
            actions: [replyAction, markReadAction, viewAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([messageCategory])
    }

    func showNotification(
        title: String,
        body: String,
        threadId: String,
        senderId: String,
        avatarUrl: String? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "MESSAGE_CATEGORY"

        // Store metadata for handling actions
        content.userInfo = [
            "threadId": threadId,
            "senderId": senderId,
            "type": "message"
        ]

        // Add avatar if available
        if let avatarUrl = avatarUrl,
           let url = URL(string: avatarUrl),
           let attachment = try? UNNotificationAttachment(
            identifier: "avatar",
            url: url,
            options: nil
           ) {
            content.attachments = [attachment]
        }

        // Create request with unique identifier
        let identifier = "message-\(threadId)-\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Immediate delivery
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge, .list])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let threadId = userInfo["threadId"] as? String else {
            completionHandler()
            return
        }

        switch response.actionIdentifier {
        case "REPLY_ACTION":
            if let textResponse = response as? UNTextInputNotificationResponse {
                handleQuickReply(text: textResponse.userText, threadId: threadId)
            }

        case "MARK_READ_ACTION":
            handleMarkAsRead(threadId: threadId)

        case "VIEW_ACTION", UNNotificationDefaultActionIdentifier:
            // Open app and navigate to conversation
            handleViewConversation(threadId: threadId)

        default:
            break
        }

        completionHandler()
    }

    // MARK: - Action Handlers

    private func handleQuickReply(text: String, threadId: String) {
        // Post notification to WebView to send message
        NotificationCenter.default.post(
            name: .sendQuickReply,
            object: nil,
            userInfo: ["text": text, "threadId": threadId]
        )

        print("Quick reply: \(text) to thread: \(threadId)")
    }

    private func handleMarkAsRead(threadId: String) {
        // Post notification to WebView to mark as read
        NotificationCenter.default.post(
            name: .markAsRead,
            object: nil,
            userInfo: ["threadId": threadId]
        )

        print("Mark as read: \(threadId)")
    }

    private func handleViewConversation(threadId: String) {
        // Activate app and open conversation
        NSApp.activate(ignoringOtherApps: true)

        NotificationCenter.default.post(
            name: .openConversation,
            object: nil,
            userInfo: ["threadId": threadId]
        )

        print("View conversation: \(threadId)")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let sendQuickReply = Notification.Name("sendQuickReply")
    static let markAsRead = Notification.Name("markAsRead")
    static let openConversation = Notification.Name("openConversation")
}
