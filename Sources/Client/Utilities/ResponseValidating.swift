//
//  ResponseValidating.swift
//  
//
//  Created by Sadık Kemal Sarı on 1.08.2024.
//

import Foundation

public protocol ResponseValidating {
    func resolve(urlResponse: URLResponse, data: Data?) throws
}

/// Validates HTTP response status codes and throws errors for non-successful responses.
public struct StandardResponseValidator: ResponseValidating {
    public init() { }

    public func resolve(urlResponse: URLResponse, data: Data?) throws {
        guard let response = urlResponse as? HTTPURLResponse else {
            throw ResponseMetadataError.noResponse
        }

        switch response.statusCode {
        case 200...299:
            // Successful response
            return
        case 300...399:
            // Redirection response
            let info = info(data: data)
            throw ResponseMetadataError.redirection(code: response.statusCode, info: info)
        case 400...499:
            // Client error response
            let info = info(data: data)
            throw ResponseMetadataError.clientError(code: response.statusCode, info: info)
        case 500...599:
            // Server error response
            let info = info(data: data)
            throw ResponseMetadataError.serverError(code: response.statusCode, info: info)
        default:
            // Unexpected status code
            let info = info(data: data)
            throw ResponseMetadataError.unexpectedStatusCode(code: response.statusCode, info: info)
        }
    }

    private func info(data: Data?) -> [String: Any] {
        guard let data = data else { return .init() }
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = json as? [String: Any] else { return .init() }
        return dict
    }
}

public enum ResponseMetadataError: Error {
    case noResponse
    case redirection(code: Int, info: [String: Any])
    case clientError(code: Int, info: [String: Any])
    case serverError(code: Int, info: [String: Any])
    case unexpectedStatusCode(code: Int, info: [String: Any])
}
