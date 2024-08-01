//
//  Endpoint.swift
//
//
//  Created by Sadık Kemal Sarı on 1.08.2024.
//

import Foundation

/// `Endpoint` defines the requirements for a network endpoint.
public protocol Endpoint {
    associatedtype RequestBodyEncoder: RequestBodyEncoding
    associatedtype ResponseDecoder: ResponseDecoding
    var path: String { get }
    var queryItems: [String: String]? { get }
    var httpMethod: HttpMethod { get }
    var headers: [String: String] { get }
    var requestBody: RequestBodyEncoder.RequestBody? { get }
    var requestBodyEncoder: RequestBodyEncoder { get }
    var responseDecoder: ResponseDecoder { get }
    var requiresAuthentication: Bool { get }
}
