//
//  HTTPURLResponseTests.swift
//  RedditXTests
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Quick
import Nimble

@testable import NetworkerX

class HTTPURLResponseTests: QuickSpec {
    override func spec() {
        context("when accessing networkError") {
            var httpURLResponse: HTTPURLResponse!

            it("should return nil if the status code is between 200-299") {
                for statusCode in 200...299 {
                    httpURLResponse = HTTPURLResponse(url: URL(string: "/")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
                    expect(httpURLResponse.networkError).to(beNil())
                }
            }

            it("should return .unauthorized if the status code is 401") {
                httpURLResponse = HTTPURLResponse(url: URL(string: "/")!, statusCode: 401, httpVersion: nil, headerFields: nil)
                expect(httpURLResponse.networkError).to(equal(.unauthorized))
            }

            it("should return .badRequest if the status code is between 400-499 (but not 401)") {
                for statusCode in 402...499 {
                    httpURLResponse = HTTPURLResponse(url: URL(string: "/")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
                    expect(httpURLResponse.networkError).to(equal(.badRequest))
                }

                httpURLResponse = HTTPURLResponse(url: URL(string: "/")!, statusCode: 400, httpVersion: nil, headerFields: nil)
                expect(httpURLResponse.networkError).to(equal(.badRequest))
            }

            it("should return .serverError if the status code is between 500-599") {
                for statusCode in 500...599 {
                    httpURLResponse = HTTPURLResponse(url: URL(string: "/")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
                    expect(httpURLResponse.networkError).to(equal(.serverError))
                }
            }

            it("should return .unknown for any other status code") {
                httpURLResponse = HTTPURLResponse(url: URL(string: "/")!, statusCode: 100, httpVersion: nil, headerFields: nil)
                expect(httpURLResponse.networkError).to(equal(.unknown))
            }
        }
    }
}
