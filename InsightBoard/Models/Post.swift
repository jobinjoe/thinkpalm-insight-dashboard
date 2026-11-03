//
//  Post.swift
//  InsightBoard
//

import Foundation

struct Post: Codable, Identifiable, Hashable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
