//
//  File.swift
//  RadioBrowserKit
//
//  Created by Simo on 9/6/2025.
//

import Foundation

/// Errors that can occur during API interaction
public enum RadioBrowserError: Error {
    /// Underlying network or transport error
    case networkError(Error)
    /// Non-200 HTTP response
    case httpError(statusCode: Int)
    /// JSON decoding failure
    case decodingError(Error)
    /// No healthy servers available
    case noServerAvailable
}
