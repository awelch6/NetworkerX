//
//  RequestManagerTests.swift
//  RedditXTests
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Quick
import Nimble

@testable import NetworkerX

class RequestManagerTests: QuickSpec {
    override func spec() {

        let url = URL(string: "https://mock/url.com")!
        var request: RequestManager!

        context("when building a request") {
            var urlRequest: URLRequest!

            beforeEach {
                request = RequestManager()
                urlRequest = request.buildRequest(url: url, method: .get)
            }

            it("should have the correct timeout interval") {
                expect(urlRequest?.timeoutInterval).to(equal(5.0))
            }

            it("should have the correct cache policy") {
                expect(urlRequest?.cachePolicy).to(equal(.reloadIgnoringCacheData))
            }

            it("should have the correct http method") {
                expect(urlRequest?.httpMethod).to(equal(HTTPMethod.get.rawValue))
            }

            it("should add headers if they exist") {
                urlRequest = request.buildRequest(url: url, method: .get, headers: ["APIKey": "key-to-the-api"])

                expect(urlRequest.allHTTPHeaderFields?["APIKey"]).notTo(beNil())
            }

            it("should add parameters if they exist") {

                let parameters: Parameters = ["page": 2, "line": 43]

                urlRequest = request.buildRequest(url: url, method: .get, parameters: parameters)

                guard let data = urlRequest.httpBody else {
                    return fail("Expected urlRequest body, but got: \(String(describing: urlRequest.httpBody))")
                }

                guard let urlRequestBody = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    return fail("Unable to serialize request body")
                }

                parameters.keys.forEach { expect(urlRequestBody[$0]).notTo(beNil()) }
            }

            it("should return nil if paramters encoding fails") {
                let bogusStr = String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian)!
                let invalidParameters: Parameters = [bogusStr: 2]

                urlRequest = request.buildRequest(url: url, method: .get, parameters: invalidParameters)

                expect(urlRequest).to(beNil())
            }
        }

        context("when handling a response") {

            beforeEach {
                request = RequestManager()
            }

            it("should call completion with .failure(.unknown) if there is an error when handling a response") {
                request.handleResponse(data: nil, response: nil, error: NSError(), { (_ response: NetworkResponse<MockModel>) in
                    expect({
                        guard case .failure(.unknown) = response else {
                            return .failed(reason: "Expected failure of type .unknown but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }

            it("should call completion with .failure(.noResponse) if the URL response cannot be casted to HTTPURLResponse") {
                request.handleResponse(data: nil, response: nil, error: nil, { (_ response: NetworkResponse<MockModel>) in
                    expect({
                        guard case .failure(.noResponse) = response else {
                            return .failed(reason: "Expected failure of type .noResponse but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }

            it("should call completion with .unableToParseData if the code is 200 but the data is nil") {
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

                request.handleResponse(data: nil, response: response, error: nil, { (_ response: NetworkResponse<MockModel>) in

                    expect({
                        guard case .failure(.unableToParseData) = response else {
                            return .failed(reason: "Expected failure of type .noResponse but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }

            it("should call completion with .unableToParseData if the code is 200 but the data is in the wrong format") {
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

                let data =
                    """
                    {
                        "id": "123",
                        "malformatted_property": "3"
                    }
                    """.data(using: .utf8)!

                request.handleResponse(data: data, response: response, error: nil, { (_ response: NetworkResponse<MockModel>) in

                    expect({
                        guard case .failure(.unableToParseData) = response else {
                            return .failed(reason: "Expected failure of type .noResponse but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }

            it("should call completion with success if the code is 200 and the data is correctly formatted") {
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

                let data =
                    """
                    {
                        "id": "123",
                        "name": "Austin"
                    }
                    """.data(using: .utf8)!

                request.handleResponse(data: data, response: response, error: nil, { (_ response: NetworkResponse<MockModel>) in

                    expect({
                        guard case .success = response else {
                            return .failed(reason: "Expected type .success but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }

            it("should call completion with .badRequest if the response code is 400") {
                let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)

                request.handleResponse(data: nil, response: response, error: nil, { (_ response: NetworkResponse<MockModel>) in

                    expect({
                        guard case .failure(.badRequest) = response else {
                            return .failed(reason: "Expected failure of type .badRequest but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }

            it("should call completion with .serverError if the response code is 500") {
                let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)

                request.handleResponse(data: nil, response: response, error: nil, { (_ response: NetworkResponse<MockModel>) in

                    expect({
                        guard case .failure(.serverError) = response else {
                            return .failed(reason: "Expected failure of type .serverError but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }

            it("should call completion with .unknown if the response code is not in the valid range (200-299) nor in the bad request or server error range (400-599)") {
                let response = HTTPURLResponse(url: url, statusCode: 600, httpVersion: nil, headerFields: nil)

                request.handleResponse(data: nil, response: response, error: nil, { (_ response: NetworkResponse<MockModel>) in
                    expect({
                        guard case .failure(.unknown) = response else {
                            return .failed(reason: "Expected failure of type .unknown but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }
        }

        context("when calling request<T>(_:_:_:_:_:)") {

            beforeEach {
                request = RequestManager()
            }

            it("should set the current task to a new session data task") {
                request.request(type: MockModel.self, url: url, method: .get, { _ in
                    expect(request.currentTask).notTo(beNil())
                })
            }

            it("should not set the current task to a new session data task if a request is unable to be created") {
                let bogusStr = String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian)!
                let invalidParameters: Parameters = [bogusStr: 2]

                request.request(type: MockModel.self, url: url, method: .get, parameters: invalidParameters, { response in
                    expect({
                        guard case .failure(.badRequest) = response else {
                            return .failed(reason: "Expected failure of type .badRequest but got: \(response)")
                        }
                        return .succeeded
                    }).to(succeed())
                })
            }
        }

        context("when calling request(_:_:_:_:)") {

            var mockURLSession: MockURLSession!

            beforeEach {
                mockURLSession = MockURLSession.shared as? MockURLSession
                request = RequestManager(session: mockURLSession)

            }

            it("should set the current task to a new session data task") {
                request.request(url: url, method: .get, { _, _, _ in })

                expect(request.currentTask).notTo(beNil())
            }

            it("should not set the current task to a new session data task if a request is unable to be created") {
                let bogusStr = String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian)!
                let invalidParameters: Parameters = [bogusStr: 2]

                request.request(url: url, method: .get, parameters: invalidParameters, { _, _, error in
                    expect(error).to(equal(.badRequest))
                })
            }

            it("should complete with a .noResponse error if the response cannot be cast to an HTTPURLResponse") {
                mockURLSession.urlResponse = nil

                request.request(url: url, method: .post, { (_, _, error) in
                    expect(error).to(equal(.noResponse))
                })
            }

            it("should complete with networkError if the response fails due to network error") {
                mockURLSession.urlResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)

                request.request(url: url, method: .post, { (_, _, error) in
                    expect(error).to(equal(.unauthorized))
                })
            }

            it("should complete with data when everything succeeds") {
                mockURLSession.urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
                mockURLSession.data =
                    """
                    {
                        name: Austin
                    }
                """.data(using: .utf8)

                request.request(url: url, method: .get, { (data, _, _) in
                    expect(data).notTo(beNil())
                })
            }
        }
    }
}
