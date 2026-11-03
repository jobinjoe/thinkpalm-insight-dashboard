//
//  StateViews.swift
//  InsightBoard
//

import SwiftUI

struct DashboardLoadingView: View {
    @State private var width: CGFloat = 390

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Fetching the workspace")
                        .font(.subheadline.weight(.medium))
                }
                .accessibilityElement(children: .combine)

                VStack(alignment: .leading, spacing: 8) {
                    skeleton(width: 148, height: 14, radius: 6)
                    skeleton(width: 230, height: 18, radius: 6)
                }

                LazyVGrid(columns: Theme.metricColumns(for: width), spacing: Theme.cardSpacing) {
                    ForEach(0..<4, id: \.self) { _ in
                        skeleton(height: 118)
                    }
                }

                skeleton(height: 156)

                skeleton(width: 72, height: 18, radius: 6)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.cardSpacing) {
                        ForEach(0..<4, id: \.self) { _ in
                            skeleton(width: 168, height: 132)
                        }
                    }
                    .padding(.horizontal, Theme.pagePadding)
                }
                .padding(.horizontal, -Theme.pagePadding)

                skeleton(width: 72, height: 18, radius: 6)
                ForEach(0..<4, id: \.self) { _ in
                    skeleton(height: 104)
                }
            }
            .padding(.horizontal, Theme.pagePadding)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .allowsHitTesting(false)
        .contentMargins(.bottom, 28, for: .scrollContent)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            width = newWidth
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading workspace")
    }

    private func skeleton(width: CGFloat? = nil, height: CGFloat, radius: CGFloat = Theme.cardRadius) -> some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(Color.primary.opacity(0.08))
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}

struct ErrorStateView: View {
    var title = "Unable to Load"
    var systemImage = "wifi.exclamationmark"
    let message: String
    var retryTitle = "Try Again"
    var isCompact = false
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            Button(retryTitle, action: retry)
                .buttonStyle(.borderedProminent)
                .controlSize(isCompact ? .regular : .large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
