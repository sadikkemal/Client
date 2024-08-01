//
//  ResponseDecoding.swift
//
//
//  Created by Sadık Kemal Sarı on 1.08.2024.
//

import Foundation

public protocol ResponseDecoding {
    associatedtype Response
    func decode(_ data: Data) throws -> Response
}

/// Decodes raw response data.
public struct RawResponseDecoder: ResponseDecoding {
    public init() { }

    public func decode(_ data: Data) throws -> Data {
        data
    }
}

/// Decodes response data as JSON.
public struct JsonResponseDecoder<Response: Decodable>: ResponseDecoding {
    public let decoder: JSONDecoder

    public init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }

    public func decode(_ data: Data) throws -> Response {
        try decoder.decode(Response.self, from: data)
    }
}
