//
//  MockURLSession.swift
//  RedditXTests
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//
import Foundation

class MockURLSession: URLSession {

    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?

    override class var shared: URLSession {
        return MockURLSession()
    }

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(data, urlResponse, error)

        return MockURLSessionDataTask()
    }
}

class MockURLSessionDataTask: URLSessionDataTask {

    override func resume() { }
}
