//
//  RootView.swift
//  InsightBoard
//

import SwiftUI

struct RootView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var model: DashboardViewModel

    init(repository: any DashboardRepository) {
        _model = State(initialValue: DashboardViewModel(repository: repository))
    }

    var body: some View {
        @Bindable var model = model

        NavigationStack {
            Group {
                if sizeClass == .regular {
                    regularLayout
                } else {
                    DashboardView(model: model, showsSelection: false)
                        .navigationDestination(item: $model.selectedPostID) { postID in
                            detail(for: postID, showsCloseButton: false)
                        }
                }
            }
            .navigationTitle("InsightBoard")
            .navigationBarTitleDisplayMode(sizeClass == .regular ? .inline : .large)
            .searchable(
                text: $model.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search posts or authors"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await model.load() }
                    } label: {
                        if model.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(model.isLoading)
                    .accessibilityLabel("Refresh")
                }
            }
        }
        .task {
            await model.loadIfNeeded()
        }
    }

    private var regularLayout: some View {
        HStack(spacing: 0) {
            DashboardView(model: model, showsSelection: model.selectedPostID != nil)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let selectedPostID = model.selectedPostID {
                Divider()
                detail(for: selectedPostID, showsCloseButton: true)
                    .containerRelativeFrame(.horizontal, alignment: .topLeading) { width, _ in
                        min(460, max(340, width * 0.38))
                    }
                    .frame(maxHeight: .infinity)
            }
        }
        .animation(.snappy(duration: 0.28), value: model.selectedPostID)
        .background(Theme.pageBackground)
    }

    @ViewBuilder
    private func detail(for postID: Int, showsCloseButton: Bool) -> some View {
        if let post = model.post(id: postID) {
            PostDetailView(
                post: post,
                author: model.author(forUserID: post.userId),
                repository: model.repository,
                showsCloseButton: showsCloseButton,
                onClose: { model.selectedPostID = nil }
            )
            .id(post.id)
        } else {
            ContentUnavailableView(
                "Post Unavailable",
                systemImage: "doc",
                description: Text("This post is no longer in the workspace.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
}

#if DEBUG
extension RootView {
    init(preview repository: any DashboardRepository, phase: DashboardViewModel.Phase, searchText: String = "") {
        let model = DashboardViewModel(repository: repository)
        model.applyPreview(phase: phase, searchText: searchText)
        _model = State(initialValue: model)
    }
}
#endif
