//
//  APIEndpoint.swift
//  InsightBoard
//

import Foundation

enum APIEndpoint {
    case users
    case posts
    case comments
    case commentsForPost(Int)
    case todos
    case albums

    private static let origin = "https://jsonplaceholder.typicode.com"

    var path: String {
        switch self {
        case .users:
            "/users"
        case .posts:
            "/posts"
        case .comments:
            "/comments"
        case .commentsForPost(let postID):
            "/posts/\(postID)/comments"
        case .todos:
            "/todos"
        case .albums:
            "/albums"
        }
    }

    func makeRequest() throws -> URLRequest {
        guard let url = URL(string: Self.origin + path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
