//
//  Client.swift
//
//
//  Created by Sadık Kemal Sarı on 1.08.2024.
//

import Foundation

/// `Client` is responsible for making network requests and handling responses.
final public class Client<
    ResponseValidator: ResponseValidating,
    TokenProvider: TokenProviding,
    Logger: Logging
>: ObservableObject {
    private let configuration: Configuration
    private let responseMetadataResolver: ResponseValidator
    private let tokenProvider: TokenProvider?
    private let logger: Logger?
    private let urlSession: URLSession

    public init(
        configuration: Configuration,
        responseMetadataResolver: ResponseValidator = StandardResponseValidator(),
        tokenProvider: TokenProvider? = nil,
        logger: Logger? = nil,
        urlSession: URLSession = .shared
    ) {
        self.configuration = configuration
        self.tokenProvider = tokenProvider
        self.responseMetadataResolver = responseMetadataResolver
        self.logger = logger
        self.urlSession = urlSession
    }
}

// MARK: - Helpers

private extension Client {
    /// Constructs a URLRequest from the specified endpoint.
    /// - Parameter endpoint: The endpoint to construct the request from.
    /// - Returns: A configured URLRequest.
    /// - Throws: An error if the URL is invalid or if the token provider is empty when required.
    private func urlRequest<T: Endpoint>(_ endpoint: T) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = configuration.scheme
        components.host = configuration.host
        components.port = configuration.port
        components.path = configuration.path + endpoint.path
        components.queryItems = endpoint.queryItems?
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { throw ClientError.invalidUrl }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        endpoint.headers.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        if endpoint.requiresAuthentication {
            guard let tokenProvider else { throw ClientError.emptyTokenProvider }
            let value = (tokenProvider.type) + " " + (try tokenProvider.credentials)
            request.addValue(value, forHTTPHeaderField: "Authorization")
        }
        if let contentType = endpoint.requestBodyEncoder.contentType {
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        if let requestBody = endpoint.requestBody {
            request.httpBody = try endpoint.requestBodyEncoder.encode(requestBody)
        }
        return request
    }
}

// MARK: - API

public extension Client {
    /// Fetches data for the specified endpoint.
    /// - Parameter endpoint: The endpoint to fetch data from.
    /// - Returns: The decoded response.
    /// - Throws: An error if the request fails or the data is invalid.
    func data<T: Endpoint>(_ endpoint: T) async throws -> T.ResponseDecoder.Response {
        let urlRequest = try urlRequest(endpoint)
        let dataSession = DataSession(
            responseDecoder: endpoint.responseDecoder,
            responseMetadataResolver: responseMetadataResolver,
            urlSession: urlSession,
            urlRequest: urlRequest)
        if let logger {
            let log = """
            Data session: \(urlRequest.hashValue):
            URL: \(String(describing: urlRequest.url?.description))
            Headers: \(String(describing: urlRequest.allHTTPHeaderFields))
            Body: \(String(describing: urlRequest.httpBody))
            """
            logger.log(log)
        }
        let response = try await dataSession.data()
        if let logger {
            let log = """
            Data session: \(urlRequest.hashValue):
            URL: \(String(describing: urlRequest.url?.description))
            Response: \(String(describing: response))
            """
            logger.log(log)
        }
        return response
    }

    /// Streams data for the specified endpoint.
    /// - Parameter endpoint: The endpoint to stream data from.
    /// - Returns: An async throwing stream of decoded responses.
    /// - Throws: An error if the request fails.
    func stream<T: Endpoint>(_ endpoint: T) throws -> AsyncThrowingStream<T.ResponseDecoder.Response, Error> {
        let urlRequest = try urlRequest(endpoint)
        let streamSession = StreamSession(
            responseDecoder: endpoint.responseDecoder,
            responseMetadataResolver: responseMetadataResolver,
            urlSession: urlSession,
            urlRequest: urlRequest)
        if let logger {
            let log = """
            Data session: \(urlRequest.hashValue):
            URL: \(String(describing: urlRequest.url?.description))
            Headers: \(String(describing: urlRequest.allHTTPHeaderFields))
            Body: \(String(describing: urlRequest.httpBody))
            """
            logger.log(log)
        }
        let response = streamSession.stream()
        if let logger {
            let log = """
            Data session: \(urlRequest.hashValue):
            URL: \(String(describing: urlRequest.url?.description))
            Response: \(String(describing: response))
            """
            logger.log(log)
        }
        return response
    }
}
