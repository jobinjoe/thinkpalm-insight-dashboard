//
//  DashboardCards.swift
//  InsightBoard
//

import Foundation
import SwiftUI

struct DashboardMetric: Identifiable {
    let id: String
    let title: String
    let value: String
    let footnote: String
    let systemImage: String
}

extension DashboardSnapshot {
    var metrics: [DashboardMetric] {
        [
            DashboardMetric(
                id: "people",
                title: "People",
                value: users.count.formatted(),
                footnote: "Authors",
                systemImage: "person.2"
            ),
            DashboardMetric(
                id: "posts",
                title: "Posts",
                value: posts.count.formatted(),
                footnote: "Published",
                systemImage: "doc.text"
            ),
            DashboardMetric(
                id: "comments",
                title: "Comments",
                value: comments.count.formatted(),
                footnote: "Across posts",
                systemImage: "text.bubble"
            ),
            DashboardMetric(
                id: "albums",
                title: "Albums",
                value: albums.count.formatted(),
                footnote: "Photo sets",
                systemImage: "photo.on.rectangle"
            ),
        ]
    }
}

struct MetricCard: View {
    let metric: DashboardMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: metric.systemImage)
                .font(.body.weight(.semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .frame(width: 36, height: 36)
                .background(Theme.accentWash, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.value)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(metric.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(metric.footnote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .cardSurface()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(metric.title), \(metric.value), \(metric.footnote)")
    }
}

struct TaskProgressCard: View {
    let snapshot: DashboardSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tasks")
                        .font(.headline)
                    Text(statusLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 12)
                Text(snapshot.completionRate.formatted(.percent.precision(.fractionLength(0))))
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(Color.accentColor)
            }

            ProgressView(value: snapshot.completionRate)
                .tint(Color.accentColor)
                .accessibilityLabel("Task completion")
                .accessibilityValue(statusLine)

            if !snapshot.openTodos.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    Text("Still open")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(Array(snapshot.openTodos.prefix(3))) { todo in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 3)
                                .accessibilityHidden(true)
                            Text(DisplayText.sentenceCase(todo.title))
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private var statusLine: String {
        if snapshot.todos.isEmpty {
            return "No tasks yet"
        }
        return "\(snapshot.completedTodoCount.formatted()) of \(snapshot.todos.count.formatted()) complete"
    }
}

struct TeamMemberCard: View {
    let user: User
    let postCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AvatarView(name: user.name, seed: user.id, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(user.company.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text("\(postCount.formatted()) posts")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.accentWash, in: Capsule())
        }
        .padding(14)
        .frame(width: 176, alignment: .leading)
        .frame(minHeight: 148, alignment: .topLeading)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }
}

struct PostCard: View {
    let post: Post
    let author: User?
    let commentCount: Int
    var isSelected = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(name: author?.name ?? "?", seed: author?.id ?? post.userId, size: 40)
            VStack(alignment: .leading, spacing: 6) {
                Text(DisplayText.sentenceCase(post.title))
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(DisplayText.singleLine(post.body))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                HStack(spacing: 6) {
                    Text(author?.name ?? "Unknown author")
                    Text("·")
                        .accessibilityHidden(true)
                    Label("\(commentCount.formatted())", systemImage: "text.bubble")
                        .labelStyle(.titleAndIcon)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
                .accessibilityHidden(true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .cardSurface(isSelected: isSelected)
    }
}
