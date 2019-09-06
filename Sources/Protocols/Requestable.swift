//
//  Requestable.swift
//  RedditX
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Foundation

protocol Requestable {

    /// Session: Holds a reference to the current URLSession
    var session: URLSession { get set }

    /// Encoder: Determines the way in which parameters are encoded for a given URLRequest. Examples are JSONEcoding, URLEncoding, etc.
    var encoder: ParameterEncoder { get }

    /// Makes a request to the given URL with the given parameters. This method serializes the URLResponse to the given type    .
    ///
    /// - Parameters:
    ///   - type: Object that the URLResponse will be decoded into. NOTE: Needs to conform to Decodable protocol.
    ///   - url: url of the request
    ///   - method: HTTP methods of the request
    ///   - parameters: parameters to be sent with the request
    ///   - headers: headers to be sent with the request
    ///   - completion: completes with the model if the request was successful and the response was serialized into the given type. completes with an error if the request fails or response is unable to be serialzed.
    func request<T: Decodable>(type: T.Type, url: URL, method: HTTPMethod, parameters: Parameters?, headers: Headers?, _ completion: @escaping (NetworkResponse<T>) -> Void)

    /// Makes a request to the given URL with the given parameters. This method returns the raw response, data, and NetworkError
    ///
    /// - Parameters:
    ///   - url: url of the request
    ///   - method: HTTP methods of the request
    ///   - parameters: parameters to be sent with the request
    ///   - headers: headers to be sent with the request
    ///   - completion: completes with the raw data from the request.
    func request(url: URL, method: HTTPMethod, parameters: Parameters?, headers: Headers?, _ completion: @escaping (Data?, URLResponse?, NetworkError?) -> Void)

    /// Builds and formats a URLRequest from given parameters.
    ///
    /// - Parameters:
    ///   - url: url of the request
    ///   - method: HTTP methods of the request
    ///   - parameters: parameters to be sent with the request
    ///   - headers: headers to be sent with the request
    /// - Returns: returns a properly formatted URLRequest or nil if that is not possible
    func buildRequest(url: URL, method: HTTPMethod, parameters: Parameters?, headers: Headers?) -> URLRequest?

    /// Decodes the raw response data of a request.
    ///
    /// - Parameters:
    ///   - data: data coming back from the request.
    ///   - response: URLResponse from the request
    ///   - error: error coming back from the request
    ///   - completion: completes with the model if the request was successful and the response was serialized into the given type. completes with an error if the request fails or response is unable to be serialzed.
    func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, _ completion: @escaping (NetworkResponse<T>) -> Void)
}
