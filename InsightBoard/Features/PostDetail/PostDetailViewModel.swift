//
//  PostDetailViewModel.swift
//  InsightBoard
//

import Foundation
import Observation

@Observable
final class PostDetailViewModel {
    private let postID: Int
    private let repository: any DashboardRepository

    private(set) var phase: Phase = .loading
    private var requestID = 0

    enum Phase: Equatable {
        case loading
        case loaded([Comment])
        case failed(String)
    }

    init(postID: Int, repository: any DashboardRepository) {
        self.postID = postID
        self.repository = repository
    }

    var comments: [Comment] {
        if case .loaded(let comments) = phase { return comments }
        return []
    }

    func loadIfNeeded() async {
        if case .loaded = phase { return }
        await load()
    }

    func load() async {
        requestID += 1
        let requestID = requestID
        if comments.isEmpty {
            phase = .loading
        }

        do {
            let loaded = try await repository.comments(for: postID)
            guard requestID == self.requestID else { return }
            phase = .loaded(loaded.sorted { $0.id < $1.id })
        } catch {
            guard requestID == self.requestID, !APIError.isCancellation(error) else { return }
            phase = .failed(APIError.message(for: error))
        }
    }
}
