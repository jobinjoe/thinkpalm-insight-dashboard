//
//  Todo.swift
//  InsightBoard
//

import Foundation

struct Todo: Codable, Identifiable, Hashable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
