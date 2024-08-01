//
//  RequestBodyEncoding.swift
//
//
//  Created by Sadık Kemal Sarı on 1.08.2024.
//

import Foundation
import FormDataEncoder

public protocol RequestBodyEncoding {
    associatedtype RequestBody
    var contentType: String? { get }
    func encode(_ requestBody: RequestBody) throws -> Data
}

/// Encodes raw request body data.
public struct RawRequestBodyEncoder: RequestBodyEncoding {
    public let contentType: String?

    public init(contentType: String? = nil) {
        self.contentType = contentType
    }

    public func encode(_ requestBody: Data) throws -> Data {
        requestBody
    }
}

/// Encodes request body data as JSON.
public struct JsonRequestBodyEncoder<RequestBody: Encodable>: RequestBodyEncoding {
    public let contentType: String?
    public let encoder: JSONEncoder

    public init(
        contentType: String? = "application/json",
        encoder: JSONEncoder = .init()
    ) {
        self.contentType = contentType
        self.encoder = encoder
    }

    public func encode(_ requestBody: RequestBody) throws -> Data {
        try encoder.encode(requestBody)
    }
}

/// Encodes request body data as form data.
public struct FormDataRequestBodyEncoder<RequestBody: Encodable>: RequestBodyEncoding {
    public let contentType: String?
    public let encoder: FormDataEncoder

    public init(
        contentType: String? = nil,
        encoder: FormDataEncoder = .init()
    ) {
        if let contentType {
            self.contentType = contentType
        } else {
            self.contentType = "multipart/form-data; boundary=\(encoder.boundary)"
        }
        self.encoder = encoder
    }

    public func encode(_ requestBody: RequestBody) throws -> Data {
        try encoder.encode(requestBody)
    }
}
