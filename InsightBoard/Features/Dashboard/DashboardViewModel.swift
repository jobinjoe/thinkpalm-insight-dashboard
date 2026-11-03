//
//  DashboardViewModel.swift
//  InsightBoard
//

import Foundation
import Observation

@Observable
final class DashboardViewModel {
    let repository: any DashboardRepository

    private(set) var phase: Phase = .loading
    var searchText = ""
    var selectedPostID: Int?

    private var hasStartedInitialLoad = false
    private var loadGeneration = 0

    enum Phase: Equatable {
        case loading
        case loaded(DashboardSnapshot)
        case failed(String)
    }

    init(repository: any DashboardRepository) {
        self.repository = repository
    }

    var isLoading: Bool {
        if case .loading = phase { return true }
        return false
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var snapshot: DashboardSnapshot? {
        if case .loaded(let snapshot) = phase { return snapshot }
        return nil
    }

    func filteredPosts(in snapshot: DashboardSnapshot) -> [Post] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return snapshot.posts }

        return snapshot.posts.filter { post in
            post.title.localizedStandardContains(query)
                || post.body.localizedStandardContains(query)
                || snapshot.user(id: post.userId)?.name.localizedStandardContains(query) == true
                || snapshot.user(id: post.userId)?.username.localizedStandardContains(query) == true
        }
    }

    func post(id: Int) -> Post? {
        snapshot?.posts.first { $0.id == id }
    }

    func author(forUserID userID: Int) -> User? {
        snapshot?.user(id: userID)
    }

    func loadIfNeeded() async {
        if hasStartedInitialLoad { return }
        guard snapshot == nil else { return }
        await load()
    }

    func load() async {
        loadGeneration += 1
        let generation = loadGeneration

        if snapshot == nil {
            phase = .loading
        }

        do {
            let loaded = try await repository.loadDashboard()
            guard generation == loadGeneration else { return }
            phase = .loaded(loaded)
        } catch {
            guard generation == loadGeneration, !APIError.isCancellation(error) else { return }
            phase = .failed(APIError.message(for: error))
        }
    }

    #if DEBUG
    func applyPreview(phase: Phase, searchText: String) {
        self.phase = phase
        self.searchText = searchText
        hasStartedInitialLoad = true
    }
    #endif
}
