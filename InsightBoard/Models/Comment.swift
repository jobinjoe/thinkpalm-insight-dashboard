//
//  Comment.swift
//  InsightBoard
//

import Foundation

struct Comment: Codable, Identifiable, Hashable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}
