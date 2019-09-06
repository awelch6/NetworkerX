//
//  MockRequestable.swift
//  RedditXTests
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Foundation

@testable import NetworkerX

class MockRequestable: Requestable {

    var session = URLSession.shared
    var encoder: ParameterEncoder = JSONParameterEncoder()

    var requestWasCalled = 0
    var requestWasCalledWith: (type: Any, url: URL, method: HTTPMethod, parameters: Parameters?, headers: Headers?)?
    
    var handleResponseWasCalled = 0
    
    enum Mode<T: Decodable> {
        case success(T)
        case failed
    }

    var mode: Any
    var shouldFailWithError: NetworkError?

    init<T: Decodable>(mode: Mode<T>) {
        self.mode = mode
    }

    func request<T: Decodable>(type: T.Type, url: URL, method: HTTPMethod, parameters: Parameters?, headers: Headers?, _ completion: @escaping (NetworkResponse<T>) -> Void) {
        requestWasCalled += 1
        requestWasCalledWith = (type: type, url: url, method: method, parameters: parameters, headers: headers)

        guard let mode = mode as? Mode<T> else {
            preconditionFailure("Invalid mode")
        }

        switch mode {
        case .success(let model):
            completion(NetworkResponse.success(model))
        case .failed:
            completion(.failure(.badRequest))
        }
    }

    func request(url: URL, method: HTTPMethod, parameters: Parameters?, headers: Headers?, _ completion: @escaping (Data?, URLResponse?, NetworkError?) -> Void) {
        requestWasCalled += 1
        requestWasCalledWith = (type: "String", url: url, method: method, parameters: parameters, headers: headers)

        completion(nil, nil, shouldFailWithError)
    }

    func buildRequest(url: URL, method: HTTPMethod, parameters: Parameters?, headers: Headers?) -> URLRequest? {
        return nil
    }

    func handleResponse<T>(data: Data?, response: URLResponse?, error: Error?, _ completion: @escaping (NetworkResponse<T>) -> Void) where T: Decodable {
        handleResponseWasCalled += 1
    }
}

extension MockRequestable: TestResetable {
    func resetCounters() {
        requestWasCalled = 0
        handleResponseWasCalled = 0

    }
    
    func resetParameters() {
        requestWasCalledWith = nil
    }
}
