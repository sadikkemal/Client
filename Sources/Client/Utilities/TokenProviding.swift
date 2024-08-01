//
//  TokenProviding.swift
//
//
//  Created by Sadık Kemal Sarı on 1.08.2024.
//

import Foundation

public protocol TokenProviding {
    var type: String { get }
    var credentials: String { get throws }
}