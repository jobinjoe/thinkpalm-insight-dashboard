//
//  Theme.swift
//  InsightBoard
//

import SwiftUI

enum Theme {
    static let pagePadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 28
    static let cardSpacing: CGFloat = 12
    static let cardRadius: CGFloat = 16
    static let metricMinimum: CGFloat = 156
    static let metricSpacing: CGFloat = 12
    static let metricColumnCap = 4

    static var pageBackground: Color { Color(.systemGroupedBackground) }
    static var cardBackground: Color { Color(.secondarySystemGroupedBackground) }
    static var hairline: Color { Color.primary.opacity(0.08) }
    static var accentWash: Color { Color.accentColor.opacity(0.14) }

    static func metricColumnCount(for width: CGFloat) -> Int {
        let usable = max(0, width - (pagePadding * 2))
        let raw = Int((usable + metricSpacing) / (metricMinimum + metricSpacing))
        return min(metricColumnCap, max(1, raw))
    }

    static func metricColumns(for width: CGFloat) -> [GridItem] {
        let count = metricColumnCount(for: width)
        return Array(
            repeating: GridItem(.flexible(), spacing: metricSpacing, alignment: .top),
            count: count
        )
    }
}
