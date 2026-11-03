//
//  DashboardRepository.swift
//  InsightBoard
//

import Foundation

protocol DashboardRepository {
    func loadDashboard() async throws -> DashboardSnapshot
    func comments(for postID: Int) async throws -> [Comment]
}

struct LiveDashboardRepository: DashboardRepository {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    /// Starts every dashboard request together.
    /// The screen stays in the loading state until all of them succeed, so it never shows a partial workspace.
    func loadDashboard() async throws -> DashboardSnapshot {
        async let users: [User] = client.fetch(.users)
        async let posts: [Post] = client.fetch(.posts)
        async let comments: [Comment] = client.fetch(.comments)
        async let todos: [Todo] = client.fetch(.todos)
        async let albums: [Album] = client.fetch(.albums)

        try await RecordingPause.waitIfRequested(seconds: 2)

        let loadedUsers = try await users
        let loadedPosts = try await posts
        let loadedComments = try await comments
        let loadedTodos = try await todos
        let loadedAlbums = try await albums

        return DashboardSnapshot(
            users: loadedUsers,
            posts: loadedPosts,
            comments: loadedComments,
            todos: loadedTodos,
            albums: loadedAlbums
        )
    }

    func comments(for postID: Int) async throws -> [Comment] {
        try await RecordingPause.waitIfRequested(seconds: 1.2)
        return try await client.fetch(.commentsForPost(postID))
    }
}

/// Debug-only pause used while recording the walkthrough.
/// It does nothing unless the scheme is launched with `-slowLoad`.
enum RecordingPause {
    #if DEBUG
    static func waitIfRequested(seconds: Double) async throws {
        guard ProcessInfo.processInfo.arguments.contains("-slowLoad") else { return }
        try await Task.sleep(for: .seconds(seconds))
    }
    #else
    static func waitIfRequested(seconds _: Double) async throws {}
    #endif
}
