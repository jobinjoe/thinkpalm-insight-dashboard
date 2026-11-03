//
//  APIClient.swift
//  InsightBoard
//

import Foundation
import os

struct APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "com.thinkpalm.InsightBoard", category: "API")

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try endpoint.makeRequest()

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            logger.error("Request failed for \(endpoint.path, privacy: .public): \(urlError.code.rawValue, privacy: .public)")
            throw APIError.transport(urlError)
        } catch {
            logger.error("Request failed for \(endpoint.path, privacy: .public)")
            throw APIError.invalidResponse
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            logger.error("HTTP \(http.statusCode, privacy: .public) for \(endpoint.path, privacy: .public)")
            throw APIError.badStatus(http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding failed for \(endpoint.path, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw APIError.decoding
        }
    }
}
