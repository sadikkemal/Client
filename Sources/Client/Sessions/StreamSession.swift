//
//  StreamSession.swift
//
//
//  Created by Sadık Kemal Sarı on 1.08.2024.
//

import Foundation

/// `StreamSession` handles streaming data from a URL session request and decoding each chunk.
struct StreamSession<
    ResponseDecoder: ResponseDecoding,
    ResponseValidator: ResponseValidating
> {
    private let dataPrefix: String = "data: "
    private var continuation: AsyncThrowingStream<ResponseDecoder.Response, Error>.Continuation?
    private let responseDecoder: ResponseDecoder
    private let responseMetadataResolver: ResponseValidator
    private let urlSession: URLSession
    private let urlRequest: URLRequest

    public init(
        responseDecoder: ResponseDecoder,
        responseMetadataResolver: ResponseValidator,
        urlSession: URLSession,
        urlRequest: URLRequest
    ) {
        self.responseDecoder = responseDecoder
        self.responseMetadataResolver = responseMetadataResolver
        self.urlSession = urlSession
        self.urlRequest = urlRequest
    }

    /// Starts streaming data from the network, decoding each chunk.
    /// - Returns: An async throwing stream of decoded responses.
    public func stream() -> AsyncThrowingStream<ResponseDecoder.Response, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, urlResponse) = try await urlSession.bytes(for: urlRequest)
                    for try await line in bytes.lines {
                        let data = parse(line)
                        try responseMetadataResolver.resolve(urlResponse: urlResponse, data: data)
                        guard let data else { continue }
                        let response = try responseDecoder.decode(data)
                        continuation.yield(response)
                    }
                    try responseMetadataResolver.resolve(urlResponse: urlResponse, data: nil)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Parses a string to extract data if it has the expected prefix.
    /// - Parameter string: The string to parse.
    /// - Returns: The extracted data or nil if the prefix is missing.
    private func parse(_ string: String) -> Data? {
        guard string.hasPrefix(dataPrefix) else { return nil }
        let content = string.dropFirst(dataPrefix.count)
        guard !content.isEmpty else { return nil }
        let data = Data(content.utf8)
        return data
    }
}
