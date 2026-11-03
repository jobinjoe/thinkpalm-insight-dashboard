//
//  APIError.swift
//  InsightBoard
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case badStatus(Int)
    case transport(URLError)
    case decoding

    var userMessage: String {
        switch self {
        case .invalidURL, .invalidResponse:
            "InsightBoard could not reach the server."
        case .badStatus(let code):
            "The server returned an error (\(code)). Try again."
        case .transport(let urlError):
            Self.message(for: urlError)
        case .decoding:
            "The data from the server could not be read."
        }
    }

    static func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if let urlError = error as? URLError, urlError.code == .cancelled { return true }
        if case APIError.transport(let urlError) = error, urlError.code == .cancelled { return true }
        return false
    }

    static func message(for error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.userMessage
        }
        if error is DecodingError {
            return APIError.decoding.userMessage
        }
        if let urlError = error as? URLError {
            return message(for: urlError)
        }
        return "Something went wrong. Try again."
    }

    private static func message(for urlError: URLError) -> String {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .internationalRoamingOff:
            "No internet connection. Check your network and try again."
        case .timedOut:
            "The request timed out. Try again in a moment."
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .secureConnectionFailed:
            "InsightBoard could not reach the server."
        default:
            "Something went wrong. Try again."
        }
    }
}
