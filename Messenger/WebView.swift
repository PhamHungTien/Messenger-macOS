//
//  WebView.swift
//  Messenger
//
//  Created by Phạm Hùng Tiến on 3/1/26.
//

import SwiftUI
import WebKit
import UserNotifications

struct WebView: NSViewRepresentable {
    let url: URL
    @Binding var unreadCount: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> WKWebView {
        // Get or create persistent WebView (only created once, reused on restore)
        let webView = WebViewManager.shared.getOrCreateWebView(url: url, for: self, coordinator: context.coordinator)

        // Store webView reference in coordinator
        context.coordinator.webView = webView

        // Configure for macOS 26 Liquid Glass corner radius
        webView.wantsLayer = true
        if let layer = webView.layer {
            // macOS 26 Tahoe corner radius: ~11-13px for standard windows
            // System will adjust based on context (concentric curves)
            layer.masksToBounds = true
            layer.cornerRadius = 11 // macOS 26 default window corner radius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                   .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        return webView
    }

    // DEPRECATED: Moved to WebViewManager
    private func _oldScript() -> String {
        return """
        // Intercept web notifications and send to native
        (function() {
            const originalNotification = window.Notification;

            window.Notification = function(title, options) {
                // Send to native notification manager
                window.webkit.messageHandlers.notificationHandler.postMessage({
                    type: 'showNotification',
                    title: title,
                    body: options?.body || '',
                    icon: options?.icon || '',
                    tag: options?.tag || '',
                    data: options?.data || {}
                });

                // Don't show web notification
                return {
                    close: function() {},
                    addEventListener: function() {}
                };
            };

            window.Notification.permission = 'granted';
            window.Notification.requestPermission = function() {
                return Promise.resolve('granted');
            };
        })();

        // Wait for page to load
        function setupMessenger() {
            // Monitor unread count
            const updateUnreadCount = () => {
                // Try multiple selectors for unread count
                const unreadElement = document.querySelector('[aria-label*="unread"]') ||
                                     document.querySelector('[data-testid="unread_count"]') ||
                                     document.querySelector('._5nxf') ||
                                     document.querySelector('[role="navigation"] [data-visualcompletion="ignore-dynamic"]');

                if (unreadElement) {
                    const text = unreadElement.innerText || unreadElement.textContent;
                    const count = parseInt(text) || 0;
                    window.webkit.messageHandlers.notificationHandler.postMessage({
                        type: 'unreadCount',
                        count: count
                    });
                } else {
                    // No unread messages
                    window.webkit.messageHandlers.notificationHandler.postMessage({
                        type: 'unreadCount',
                        count: 0
                    });
                }
            };

            // Initial update
            updateUnreadCount();

            // Monitor DOM changes
            const observer = new MutationObserver(updateUnreadCount);
            observer.observe(document.body, { childList: true, subtree: true, attributes: true });

            // Update every 5 seconds as backup
            setInterval(updateUnreadCount, 5000);
        }

        // Run setup when DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', setupMessenger);
        } else {
            setupMessenger();
        }

        // Request notification permission on load
        if (window.Notification && Notification.permission === 'default') {
            Notification.requestPermission();
        }
        """
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebView
        weak var webView: WKWebView?

        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            setupNotificationObservers()
        }

        private func setupNotificationObservers() {
            // Listen for quick reply actions
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleQuickReply(_:)),
                name: .sendQuickReply,
                object: nil
            )

            // Listen for mark as read actions
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleMarkAsRead(_:)),
                name: .markAsRead,
                object: nil
            )

            // Listen for open conversation actions
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleOpenConversation(_:)),
                name: .openConversation,
                object: nil
            )

            // Listen for JavaScript execution requests
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleExecuteJavaScript(_:)),
                name: .executeJavaScript,
                object: nil
            )
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "notificationHandler",
               let dict = message.body as? [String: Any],
               let type = dict["type"] as? String {

                if type == "unreadCount", let count = dict["count"] as? Int {
                    DispatchQueue.main.async {
                        self.parent.unreadCount = count
                        // Update dock badge
                        NSApp.dockTile.badgeLabel = count > 0 ? "\(count)" : nil
                        // Notify menu bar manager
                        NotificationCenter.default.post(
                            name: .unreadCountChanged,
                            object: nil,
                            userInfo: ["count": count]
                        )
                    }
                } else if type == "showNotification" {
                    handleWebNotification(dict)
                }
            }
        }

        private func handleWebNotification(_ data: [String: Any]) {
            let title = data["title"] as? String ?? "New Message"
            let body = data["body"] as? String ?? ""
            let icon = data["icon"] as? String

            // Extract thread ID from data or tag
            let threadId = extractThreadId(from: data)

            DispatchQueue.main.async {
                NotificationManager.shared.showNotification(
                    title: title,
                    body: body,
                    threadId: threadId,
                    senderId: "",
                    avatarUrl: icon
                )
            }
        }

        private func extractThreadId(from data: [String: Any]) -> String {
            // Try to extract thread ID from notification data
            if let tag = data["tag"] as? String {
                return tag
            }
            if let notifData = data["data"] as? [String: Any],
               let threadId = notifData["threadId"] as? String {
                return threadId
            }
            return UUID().uuidString
        }

        @objc private func handleQuickReply(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let text = userInfo["text"] as? String else {
                return
            }

            // TODO: Use threadId for targeted message sending
            // let threadId = userInfo["threadId"] as? String

            // Inject JavaScript to send message
            let script = """
            (function() {
                // Find the message input for the thread
                const input = document.querySelector('[contenteditable="true"]');
                if (input) {
                    // Set the text
                    input.textContent = '\(text.replacingOccurrences(of: "'", with: "\\'"))';

                    // Trigger input event
                    input.dispatchEvent(new Event('input', { bubbles: true }));

                    // Find and click send button
                    setTimeout(() => {
                        const sendButton = document.querySelector('[aria-label*="Send"]') ||
                                          document.querySelector('[data-testid="send-button"]');
                        if (sendButton) {
                            sendButton.click();
                        }
                    }, 100);
                }
            })();
            """

            webView?.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Quick reply error: \(error.localizedDescription)")
                } else {
                    print("Quick reply sent successfully")
                }
            }
        }

        @objc private func handleMarkAsRead(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let threadId = userInfo["threadId"] as? String else {
                return
            }

            // TODO: Implement mark as read functionality
            // Mark conversation as read (implementation depends on Messenger's web API)
            print("Marking thread as read: \(threadId)")
        }

        @objc private func handleOpenConversation(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let _ = userInfo["threadId"] as? String else {
                return
            }

            // TODO: Navigate to specific conversation using threadId
            // For now, just bring app to foreground
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
            }
        }

        @objc private func handleExecuteJavaScript(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let script = userInfo["script"] as? String else {
                return
            }

            webView?.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("JavaScript execution error: \(error.localizedDescription)")
                }
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Allow messenger.com and facebook.com domains
            if let host = navigationAction.request.url?.host {
                if host.contains("messenger.com") || host.contains("facebook.com") {
                    decisionHandler(.allow)
                    return
                }
            }

            // Open external links in default browser
            if let url = navigationAction.request.url,
               navigationAction.navigationType == .linkActivated {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle popup windows (like image viewers)
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Navigation failed: \(error.localizedDescription)")
            showErrorAndRetry(webView: webView, error: error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Provisional navigation failed: \(error.localizedDescription)")
            showErrorAndRetry(webView: webView, error: error)
        }

        private func showErrorAndRetry(webView: WKWebView, error: Error) {
            // Auto-retry after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                print("Retrying to load Messenger...")
                let request = URLRequest(url: URL(string: "https://www.messenger.com")!)
                webView.load(request)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Messenger loaded successfully")
        }
    }
}
