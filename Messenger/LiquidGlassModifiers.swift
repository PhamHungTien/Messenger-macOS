//
//  LiquidGlassModifiers.swift
//  Messenger
//
//  Modern Liquid Glass effects with backward compatibility
//

import SwiftUI

// MARK: - Liquid Glass Extensions

extension View {
    /// Applies Liquid Glass effect when available (macOS 26+), falls back to material blur
    @ViewBuilder
    func liquidGlass(
        tint: Color? = nil,
        intensity: LiquidGlassIntensity = .regular,
        cornerStyle: GlassCornerStyle = .rounded(12)
    ) -> some View {
        // When macOS 26 is released, uncomment this:
        // if #available(macOS 26.0, *) {
        //     let shape = cornerStyle.toShape26()
        //     self.glassEffect(intensity.toGlass().tint(tint ?? .clear), in: shape)
        // } else {
            self.modernGlassEffect(tint: tint, intensity: intensity, cornerStyle: cornerStyle)
        // }
    }

    /// Legacy overload for custom shapes
    @ViewBuilder
    func liquidGlass(
        tint: Color? = nil,
        intensity: LiquidGlassIntensity = .regular,
        shape: some Shape
    ) -> some View {
        self.modernGlassEffect(tint: tint, intensity: intensity, shape: shape)
    }

    /// Modern glass effect using available materials with corner style (macOS 14+)
    @ViewBuilder
    private func modernGlassEffect(
        tint: Color?,
        intensity: LiquidGlassIntensity,
        cornerStyle: GlassCornerStyle
    ) -> some View {
        let shape = cornerStyle.toShape()
        self.modernGlassEffect(tint: tint, intensity: intensity, shape: shape)
    }

    /// Modern glass effect using available materials with custom shape (macOS 14+)
    @ViewBuilder
    private func modernGlassEffect(
        tint: Color?,
        intensity: LiquidGlassIntensity,
        shape: some Shape
    ) -> some View {
        self
            .background {
                ZStack {
                    // Base material
                    shape
                        .fill(intensity.material)

                    // Tint overlay
                    if let tint = tint {
                        shape
                            .fill(tint.opacity(0.15))
                    }

                    // Specular highlight simulation
                    LinearGradient(
                        colors: [
                            .white.opacity(0.3),
                            .clear,
                            .white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.overlay)
                    .clipShape(shape)
                }
                .shadow(
                    color: .black.opacity(0.1),
                    radius: intensity.shadowRadius,
                    y: intensity.shadowY
                )
            }
    }

    /// Interactive glass effect - responds to hover
    @ViewBuilder
    func interactiveGlass(tint: Color? = nil) -> some View {
        InteractiveGlassButton(tint: tint) {
            self
        }
    }
}

// MARK: - Glass Corner Style

/// Corner styles for glass effects, compatible with macOS 26 .rect() API
enum GlassCornerStyle {
    case rounded(CGFloat)
    case continuous(CGFloat)
    case circular
    case capsule

    /// Convert to SwiftUI Shape for macOS 14+
    func toShape() -> AnyShape {
        switch self {
        case .rounded(let radius):
            return AnyShape(RoundedRectangle(cornerRadius: radius, style: .circular))
        case .continuous(let radius):
            return AnyShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        case .circular:
            return AnyShape(Circle())
        case .capsule:
            return AnyShape(Capsule())
        }
    }

    // Future macOS 26 compatibility with .rect()
    // @available(macOS 26.0, *)
    // func toShape26() -> some Shape {
    //     switch self {
    //     case .rounded(let radius):
    //         return ConcentricRectangle.rect(corners: .rounded(radius: radius))
    //     case .continuous(let radius):
    //         return ConcentricRectangle.rect(corners: .continuous(radius: radius))
    //     case .circular:
    //         return Circle()
    //     case .capsule:
    //         return Capsule()
    //     }
    // }
}

// MARK: - Liquid Glass Intensity

enum LiquidGlassIntensity {
    case clear
    case regular
    case thick

    var material: Material {
        switch self {
        case .clear:
            return .ultraThinMaterial
        case .regular:
            return .thin
        case .thick:
            return .regular
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .clear: return 2
        case .regular: return 4
        case .thick: return 8
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .clear: return 1
        case .regular: return 2
        case .thick: return 4
        }
    }

    // Future macOS 26 compatibility
    // func toGlass() -> Glass {
    //     switch self {
    //     case .clear: return .clear
    //     case .regular: return .regular
    //     case .thick: return .regular // or custom
    //     }
    // }
}

// MARK: - Interactive Glass Button

struct InteractiveGlassButton<Content: View>: View {
    let tint: Color?
    let content: Content
    @State private var isHovering = false

    init(tint: Color?, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .liquidGlass(
                tint: tint,
                intensity: isHovering ? .thick : .regular,
                cornerStyle: .continuous(12)
            )
            .animation(.smooth(duration: 0.2), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

// MARK: - Glass Container

/// Container for grouping multiple glass elements
struct GlassContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        // Future macOS 26:
        // if #available(macOS 26.0, *) {
        //     GlassEffectContainer {
        //         content
        //     }
        // } else {
            content
        // }
    }
}

// MARK: - Preview

#Preview("Glass Effects") {
    VStack(spacing: 20) {
        Text("Clear Glass")
            .padding()
            .liquidGlass(intensity: .clear, cornerStyle: .continuous(8))

        Text("Regular Glass (Rounded)")
            .padding()
            .liquidGlass(tint: .blue, intensity: .regular, cornerStyle: .rounded(12))

        Text("Thick Glass (Continuous)")
            .padding()
            .liquidGlass(tint: .purple, intensity: .thick, cornerStyle: .continuous(16))

        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .padding(12)
                .liquidGlass(tint: .yellow, cornerStyle: .circular)

            Text("Capsule")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .liquidGlass(tint: .green, cornerStyle: .capsule)
        }

        Button("Interactive Glass") {}
            .padding()
            .interactiveGlass(tint: .orange)
    }
    .padding(40)
    .frame(width: 400, height: 600)
    .background {
        LinearGradient(
            colors: [.blue, .purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
