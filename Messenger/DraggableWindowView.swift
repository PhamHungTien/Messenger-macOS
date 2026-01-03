//
//  DraggableWindowView.swift
//  Messenger
//
//  Created by Phạm Hùng Tiến on 3/1/26.
//

import SwiftUI
import AppKit

// NSView that overlays WebView and enables window dragging from top area
class DraggableWindowNSView: NSView {
    private let dragHeight: CGFloat = 44 // Height of draggable area from top

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        // Start window drag
        window?.performDrag(with: event)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Only intercept top area for dragging
        if point.y >= self.bounds.height - dragHeight {
            return self
        }
        // Pass through to WebView below
        return nil
    }
}

// SwiftUI wrapper
struct DraggableWindowView: NSViewRepresentable {
    func makeNSView(context: Context) -> DraggableWindowNSView {
        return DraggableWindowNSView()
    }

    func updateNSView(_ nsView: DraggableWindowNSView, context: Context) {
        // No updates needed
    }
}
