//
//  WebViewManager.swift
//  Messenger
//
//  Created by Phạm Hùng Tiến on 3/1/26.
//

import SwiftUI
import WebKit
import Combine

// Singleton to keep WKWebView instance alive
class WebViewManager: ObservableObject {
    static let shared = WebViewManager()

    @Published var webView: WKWebView?
    private var coordinator: WebView.Coordinator?
    private var isInitialized = false

    private init() {}

    func getOrCreateWebView(url: URL, for parent: WebView, coordinator: WebView.Coordinator) -> WKWebView {
        if let existingWebView = webView {
            // Reuse existing WebView - don't reload
            return existingWebView
        }

        // Create new WebView only once
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences

        configuration.userContentController.add(coordinator, name: "notificationHandler")

        // Inject JavaScript for notifications and unread count
        let script = """
        // Intercept web notifications and send to native
        (function() {
            const originalNotification = window.Notification;

            window.Notification = function(title, options) {
                // Send to native notification manager
                window.webkit.messageHandlers.notificationHandler.postMessage({
                    type: 'showNotification',
                    title: title,
                    body: options?.body || '',
                    icon: options?.icon || ''
                });

                // Return a mock notification object
                return {
                    close: function() {},
                    onclick: null,
                    onerror: null
                };
            };

            window.Notification.permission = 'granted';
            window.Notification.requestPermission = function() {
                return Promise.resolve('granted');
            };
        })();

        // Detect unread message count
        function setupMessenger() {
            const updateUnreadCount = function() {
                // Try multiple selectors for unread count badge
                const selectors = [
                    '[aria-label*="unread"]',
                    '[data-testid*="unread"]',
                    '.notification-badge',
                    '[class*="badge"]'
                ];

                let unreadElement = null;
                for (const selector of selectors) {
                    unreadElement = document.querySelector(selector);
                    if (unreadElement) break;
                }

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
        """

        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)

        let newWebView = WKWebView(frame: .zero, configuration: configuration)
        newWebView.navigationDelegate = coordinator
        newWebView.uiDelegate = coordinator
        newWebView.allowsBackForwardNavigationGestures = true

        self.webView = newWebView
        self.coordinator = coordinator

        // Load URL only once
        let request = URLRequest(url: url)
        newWebView.load(request)
        isInitialized = true

        return newWebView
    }
}
