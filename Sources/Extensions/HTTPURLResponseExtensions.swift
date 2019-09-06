//
//  HTTPURLResponseExtensions.swift
//  RedditX
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    var networkError: NetworkError? {
        switch self.statusCode {
        case 200...299:
            return nil
        case 401:
            return .unauthorized
        case 400, 402...499:
            return .badRequest
        case 500...599:
            return .serverError
        default:
            return .unknown
        }
    }
}
