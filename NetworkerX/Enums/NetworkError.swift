//
//  NetworkError.swift
//  RedditX
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Foundation

/// Networking error types
public enum NetworkError: Error {

    /// Represents a response with the status code 400, 402-499
    case badRequest

    /// Represents an error when parsing the URL
    case invalidURL

    /// Represents an error when no URLResponse exists
    case noResponse

    /// Represents a response with the status code 500-599
    case serverError

    /// Represents an error when the response is unable to be decoded into an object
    case unableToParseData

    /// Represents a response with the status code 401
    case unauthorized

    /// Represents when an unknown error occurs
    case unknown
}

// MARK: Equatable

extension NetworkError: Equatable { }

// MARK: CaseIterable

extension NetworkError: CaseIterable { }
