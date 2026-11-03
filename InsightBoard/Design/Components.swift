//
//  Components.swift
//  InsightBoard
//

import SwiftUI

enum DisplayText {
    static func sentenceCase(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return trimmed }
        return first.uppercased() + trimmed.dropFirst()
    }

    static func singleLine(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct CardSurface: ViewModifier {
    var isSelected = false

    func body(content: Content) -> some View {
        content
            .background(
                Theme.cardBackground,
                in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.accentColor : Theme.hairline,
                        lineWidth: isSelected ? 2 : 1
                    )
            }
    }
}

extension View {
    func cardSurface(isSelected: Bool = false) -> some View {
        modifier(CardSurface(isSelected: isSelected))
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SectionHeader: View {
    let title: String
    var detail: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer(minLength: 8)
            if let detail {
                Text(detail)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct AvatarView: View {
    let name: String
    let seed: Int
    var size: CGFloat = 40

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.36, weight: .semibold))
            .foregroundStyle(colorScheme == .dark ? color.opacity(0.95) : color)
            .frame(width: size, height: size)
            .background(color.opacity(colorScheme == .dark ? 0.28 : 0.14), in: Circle())
            .accessibilityHidden(true)
    }

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap(\.first)
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }

    private var color: Color {
        let palette: [Color] = [
            Color(red: 0.05, green: 0.45, blue: 0.43),
            Color(red: 0.15, green: 0.36, blue: 0.62),
            Color(red: 0.40, green: 0.29, blue: 0.60),
            Color(red: 0.60, green: 0.32, blue: 0.16),
            Color(red: 0.16, green: 0.44, blue: 0.31),
            Color(red: 0.54, green: 0.20, blue: 0.34),
        ]
        return palette[abs(seed) % palette.count]
    }
}
