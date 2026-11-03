//
//  PostDetailView.swift
//  InsightBoard
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    let author: User?
    var showsCloseButton = false
    var onClose: (() -> Void)?

    @State private var model: PostDetailViewModel

    init(
        post: Post,
        author: User?,
        repository: any DashboardRepository,
        showsCloseButton: Bool = false,
        onClose: (() -> Void)? = nil
    ) {
        self.post = post
        self.author = author
        self.showsCloseButton = showsCloseButton
        self.onClose = onClose
        _model = State(initialValue: PostDetailViewModel(postID: post.id, repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if let author {
                    authorCard(author)
                } else {
                    Text("Author unavailable")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(post.body)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                commentsSection
            }
            .padding(Theme.pagePadding)
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemBackground))
        .contentMargins(.bottom, 28, for: .scrollContent)
        .refreshable {
            await model.load()
        }
        .task {
            await model.loadIfNeeded()
        }
        .modifier(PushedPostTitle(isPushed: !showsCloseButton))
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(DisplayText.sentenceCase(post.title))
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            if showsCloseButton {
                Button {
                    onClose?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color.primary.opacity(0.06), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close post")
            }
        }
    }

    private func authorCard(_ author: User) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                AvatarView(name: author.name, seed: author.id, size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(author.name)
                        .font(.headline)
                    Text("@\(author.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }

            Text(DisplayText.sentenceCase(author.company.catchPhrase))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                if let mailURL = author.mailURL {
                    Link(destination: mailURL) {
                        Label(author.email, systemImage: "envelope")
                    }
                }
                Label(author.address.city, systemImage: "mappin.and.ellipse")
                    .foregroundStyle(.primary)
                if let websiteURL = author.websiteURL {
                    Link(destination: websiteURL) {
                        Label(author.website, systemImage: "link")
                    }
                }
            }
            .font(.subheadline)
            .tint(Color.accentColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    @ViewBuilder
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Comments", detail: commentDetail)

            switch model.phase {
            case .loading:
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Loading comments")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .accessibilityElement(children: .combine)
            case .failed(let message):
                ErrorStateView(
                    title: "Comments Unavailable",
                    systemImage: "text.bubble",
                    message: message,
                    isCompact: true
                ) {
                    Task { await model.load() }
                }
                .frame(minHeight: 280)
            case .loaded(let comments) where comments.isEmpty:
                EmptyStateView(
                    title: "No Comments",
                    systemImage: "text.bubble",
                    message: "This post has no comments yet."
                )
                .frame(minHeight: 240)
            case .loaded(let comments):
                ForEach(comments) { comment in
                    commentCard(comment)
                }
            }
        }
    }

    private var commentDetail: String? {
        if case .loaded(let comments) = model.phase {
            return comments.count.formatted()
        }
        return nil
    }

    private func commentCard(_ comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DisplayText.sentenceCase(comment.name))
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text(comment.email)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(comment.body)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }
}

private struct PushedPostTitle: ViewModifier {
    let isPushed: Bool

    func body(content: Content) -> some View {
        if isPushed {
            content
                .navigationTitle("Post")
                .navigationBarTitleDisplayMode(.inline)
        } else {
            content
        }
    }
}
