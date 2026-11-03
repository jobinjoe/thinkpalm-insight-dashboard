//
//  Album.swift
//  InsightBoard
//

import Foundation

struct Album: Codable, Identifiable, Hashable {
    let userId: Int
    let id: Int
    let title: String
}
