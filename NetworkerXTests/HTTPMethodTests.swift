//
//  HTTPMethodTest.swift
//  RedditXTests
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Quick
import Nimble

@testable import NetworkerX

class HTTPMethodTests: QuickSpec {
    override func spec() {

        it("should return the correct value for a get request") {
            expect(HTTPMethod.get.rawValue).to(equal("GET"))
        }

        it("should return the correct value for a post request") {
            expect(HTTPMethod.post.rawValue).to(equal("POST"))
        }

        it("should return the correct value for a put request") {
            expect(HTTPMethod.put.rawValue).to(equal("PUT"))
        }

        it("should return the correct value for a patch request") {
            expect(HTTPMethod.patch.rawValue).to(equal("PATCH"))
        }

        it("should return the correct value for a delete request") {
            expect(HTTPMethod.delete.rawValue).to(equal("DELETE"))
        }
    }
}
