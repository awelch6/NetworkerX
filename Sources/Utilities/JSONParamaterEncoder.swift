//
//  JSONParamaterEncoder.swift
//  RedditX
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Foundation

private enum JSONEncodingError: Error {
    case unableToParse
}

public struct JSONParameterEncoder: ParameterEncoder {
    
    public init() { }
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do {
            let json = try JSONSerialization.data(withJSONObject: parameters, options: [])

            urlRequest.httpBody = json

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw JSONEncodingError.unableToParse
        }
    }
}
