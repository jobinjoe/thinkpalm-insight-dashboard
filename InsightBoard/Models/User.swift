//
//  User.swift
//  InsightBoard
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company

    struct Address: Codable, Hashable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String
        let geo: Geo
    }

    struct Geo: Codable, Hashable {
        let lat: String
        let lng: String
    }

    struct Company: Codable, Hashable {
        let name: String
        let catchPhrase: String
        let bs: String
    }

    var websiteURL: URL? {
        let host = website.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !host.isEmpty else { return nil }
        if host.contains("://") {
            return URL(string: host)
        }
        return URL(string: "https://\(host)")
    }

    var mailURL: URL? {
        let address = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else { return nil }
        return URL(string: "mailto:\(address)")
    }
}
