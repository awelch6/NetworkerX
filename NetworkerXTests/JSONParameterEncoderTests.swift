//
//  JSONParameterEncoderTests.swift
//  RedditXTests
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//
import Quick
import Nimble

@testable import NetworkerX

class JSONParameterEncoderTests: QuickSpec {
    override func spec() {

        let url = URL(string: "https://mock/url.com")!

        var request: URLRequest!

        var encoder: JSONParameterEncoder!

        let validParameters: Parameters = ["page": 2]

        beforeEach {
            request = URLRequest(url: url)
            encoder = JSONParameterEncoder()
        }

        it("should not throw if passed valid parameters") {
            expect {
                try encoder.encode(urlRequest: &request, with: validParameters)
                }.notTo(throwError())
        }

        it("should append valid parameters onto the urlRequest's body") {
            expect {
                try encoder.encode(urlRequest: &request, with: validParameters)
                }.notTo(throwError())

            guard let data = request.httpBody else {
                return fail("Expected request body, but got: \(String(describing: request.httpBody))")
            }

            guard let requestBody = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return fail("Unable to serialize request body")
            }

            validParameters.keys.forEach { expect(requestBody[$0]).notTo(beNil()) }
        }

        it("should append correct headers if passed valid parameters") {
            expect {
                try encoder.encode(urlRequest: &request, with: validParameters)
                }.notTo(throwError())

            expect(request.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
        }

        it("should not append correct headers if passed invalid parameters and should throw error") {
            let bogusStr = String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian)!
            let invalidParameters: Parameters = [bogusStr: 2]

            expect {
                try encoder.encode(urlRequest: &request, with: invalidParameters)
                }.to(throwError())

            expect(request.allHTTPHeaderFields?["Content-Type"]).to(beNil())
        }
    }
}
