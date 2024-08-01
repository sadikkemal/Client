//
//  Configuration.swift
//
//
//  Created by Sadık Kemal Sarı on 1.08.2024.
//

import Foundation

public struct Configuration {
    public let scheme: String
    public let host: String
    public let port: Int?
    public let path: String

    public init(
        scheme: String,
        host: String,
        port: Int? = nil,
        path: String
    ) {
        self.scheme = scheme
        self.host = host
        self.port = port
        self.path = path
    }
}
