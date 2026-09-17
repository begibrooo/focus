import SwiftUI

enum Theme {
    // Primary Luxury Academic Palette
    static let primary = Color(red: 0.23, green: 0.51, blue: 0.96) // Apple Electric Blue
    static let accent = Color(red: 0.98, green: 0.45, blue: 0.09)  // Flame Amber
    static let background = Color(red: 0.02, green: 0.04, blue: 0.08) // Deep Obsidian
    
    // Status Colors
    static let success = Color(red: 0.06, green: 0.72, blue: 0.51)
    static let warning = Color(red: 0.98, green: 0.62, blue: 0.14)
    static let danger = Color(red: 0.94, green: 0.27, blue: 0.27)
    
    // Skill Specific Palettes (Liquid Glow Contrast)
    static let listening = Color(red: 0.22, green: 0.74, blue: 0.97)
    static let reading = Color(red: 0.20, green: 0.83, blue: 0.60)
    static let writing1 = Color(red: 0.98, green: 0.75, blue: 0.14)
    static let writing2 = Color(red: 0.65, green: 0.55, blue: 0.98)
    static let speaking = Color(red: 0.96, green: 0.45, blue: 0.71)
    static let general = Color(red: 0.55, green: 0.60, blue: 0.72)
}

// MARK: - Liquid Glass Modifier (iOS 18 / visionOS style)
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 26
    
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.white.opacity(0.02),
                                        Color.white.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.45), radius: 16, x: 0, y: 8)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 26) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
}
