//
//  NetworkResponse.swift
//  RedditX
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Foundation

public enum NetworkResponse<T> {
    case success(T)
    case failure(NetworkError)
}
