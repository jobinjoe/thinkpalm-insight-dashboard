//
//  DashboardView.swift
//  InsightBoard
//

import Foundation
import SwiftUI

struct DashboardView: View {
    @Bindable var model: DashboardViewModel
    var showsSelection: Bool

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                DashboardLoadingView()
            case .failed(let message):
                ErrorStateView(message: message) {
                    Task { await model.load() }
                }
            case .loaded(let snapshot):
                if snapshot.isEmpty {
                    EmptyStateView(
                        title: "Nothing Here Yet",
                        systemImage: "tray",
                        message: "The workspace returned no posts, people, or tasks.",
                        actionTitle: "Reload"
                    ) {
                        Task { await model.load() }
                    }
                } else if model.isSearching {
                    searchResults(in: snapshot)
                } else {
                    loadedContent(snapshot)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pageBackground)
    }

    @ViewBuilder
    private func searchResults(in snapshot: DashboardSnapshot) -> some View {
        let posts = model.filteredPosts(in: snapshot)
        if posts.isEmpty {
            ContentUnavailableView.search(text: model.searchText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Theme.cardSpacing) {
                    SectionHeader(title: "Results", detail: posts.count.formatted())
                    postList(posts, in: snapshot)
                }
                .padding(.horizontal, Theme.pagePadding)
                .padding(.vertical, 8)
            }
            .contentMargins(.bottom, 28, for: .scrollContent)
            .refreshable {
                await model.load()
            }
        }
    }

    private func loadedContent(_ snapshot: DashboardSnapshot) -> some View {
        MeasuredDashboard { width in
            VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sample workspace")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    Text(summary(for: snapshot))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                LazyVGrid(columns: Theme.metricColumns(for: width), spacing: Theme.cardSpacing) {
                    ForEach(snapshot.metrics) { metric in
                        MetricCard(metric: metric)
                    }
                }

                if !snapshot.todos.isEmpty {
                    TaskProgressCard(snapshot: snapshot)
                }

                if !snapshot.users.isEmpty {
                    teamSection(snapshot)
                }

                VStack(alignment: .leading, spacing: Theme.cardSpacing) {
                    SectionHeader(title: "Posts", detail: snapshot.posts.count.formatted())
                    if snapshot.posts.isEmpty {
                        EmptyStateView(
                            title: "No Posts Yet",
                            systemImage: "doc.text",
                            message: "Published posts will appear here."
                        )
                        .frame(minHeight: 280)
                    } else {
                        postList(snapshot.posts, in: snapshot)
                    }
                }
            }
            .padding(.horizontal, Theme.pagePadding)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .refreshable {
            await model.load()
        }
    }

    private func teamSection(_ snapshot: DashboardSnapshot) -> some View {
        VStack(alignment: .leading, spacing: Theme.cardSpacing) {
            SectionHeader(title: "Team", detail: snapshot.users.count.formatted())

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: Theme.cardSpacing) {
                    ForEach(snapshot.users) { user in
                        TeamMemberCard(
                            user: user,
                            postCount: snapshot.postCount(for: user.id)
                        )
                    }
                }
                .padding(.horizontal, Theme.pagePadding)
            }
            .padding(.horizontal, -Theme.pagePadding)
        }
    }

    private func postList(_ posts: [Post], in snapshot: DashboardSnapshot) -> some View {
        ForEach(posts) { post in
            Button {
                model.selectedPostID = post.id
            } label: {
                PostCard(
                    post: post,
                    author: snapshot.user(id: post.userId),
                    commentCount: snapshot.commentCount(for: post.id),
                    isSelected: showsSelection && model.selectedPostID == post.id
                )
            }
            .buttonStyle(CardButtonStyle())
            .accessibilityHint("Shows the post and its comments")
            .accessibilityAddTraits(showsSelection && model.selectedPostID == post.id ? .isSelected : [])
        }
    }

    private func summary(for snapshot: DashboardSnapshot) -> String {
        let people = snapshot.users.count.formatted()
        let posts = snapshot.posts.count.formatted()
        guard !snapshot.todos.isEmpty else {
            return "\(people) people · \(posts) posts"
        }
        let percent = snapshot.completionRate.formatted(.percent.precision(.fractionLength(0)))
        return "\(people) people · \(posts) posts · \(percent) of tasks done"
    }
}

private struct MeasuredDashboard<Content: View>: View {
    @ViewBuilder var content: (CGFloat) -> Content
    @State private var width: CGFloat = 390

    var body: some View {
        ScrollView {
            content(width)
        }
        .contentMargins(.bottom, 28, for: .scrollContent)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            width = newWidth
        }
    }
}
