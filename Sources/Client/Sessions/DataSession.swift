//
//  DataSession.swift
//
//
//  Created by Sadık Kemal Sarı on 01.08.2024.
//

import Foundation

/// `DataSession` handles fetching and decoding data from a URL session request.
struct DataSession<
    ResponseDecoder: ResponseDecoding,
    ResponseValidator: ResponseValidating
> {
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

    /// Fetches data from the network and decodes it into the specified response type.
    /// - Returns: The decoded response.
    /// - Throws: An error if the request fails or the data is invalid.
    public func data() async throws -> ResponseDecoder.Response {
        let (data, urlResponse) = try await urlSession.data(for: urlRequest)
        try responseMetadataResolver.resolve(urlResponse: urlResponse, data: data)
        return try responseDecoder.decode(data)
    }
}
