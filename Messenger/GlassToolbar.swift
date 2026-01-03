//
//  GlassToolbar.swift
//  Messenger
//
//  Created by Phạm Hùng Tiến on 3/1/26.
//
//  NOTE: This is an example component showing custom glass UI.
//  The main app uses native .toolbar API following Apple HIG.
//  This file is kept for reference and can be used for custom overlays if needed.
//

import SwiftUI

struct GlassToolbar: View {
    @Binding var unreadCount: Int
    @State private var isSearching = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            // App icon
            Image(systemName: "message.fill")
                .font(.title2)
                .foregroundStyle(.tint)
                .padding(8)
                .liquidGlass(tint: .blue.opacity(0.5), cornerStyle: .circular)

            Spacer()

            // Search button
            Button {
                isSearching.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .padding(8)
            .interactiveGlass()

            // New message button
            Button {
                NotificationCenter.default.post(name: .newMessage, object: nil)
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .padding(8)
            .interactiveGlass(tint: .blue)

            // Unread count badge
            if unreadCount > 0 {
                Text("\(unreadCount)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(.red.gradient)
                    }
                    .liquidGlass(tint: .red.opacity(0.3), cornerStyle: .capsule)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    GlassToolbar(unreadCount: .constant(5))
        .padding()
        .frame(height: 60)
        .background {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
}
