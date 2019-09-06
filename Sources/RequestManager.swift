//
//  Request.swift
//  RedditX
//
//  Created by Austin Welch on 9/6/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Foundation

public typealias Headers = [String: String]
public typealias Parameters = [String: Any]

public class RequestManager {

    public var session: URLSession
    public var encoder: ParameterEncoder

    public var currentTask: URLSessionDataTask?

    public init(session: URLSession = URLSession.shared, encoder: ParameterEncoder = JSONParameterEncoder()) {
        self.session = session
        self.encoder = encoder
    }
}

// MARK: Requestable

extension RequestManager: Requestable {

    public func request<T: Decodable>(type: T.Type, url: URL, method: HTTPMethod, parameters: Parameters? = nil, headers: Headers? = nil, _ completion: @escaping (NetworkResponse<T>) -> Void) {

        guard let request = buildRequest(url: url, method: method, parameters: parameters, headers: headers) else {
            completion(.failure(.badRequest))
            return
        }

        currentTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                self?.handleResponse(data: data, response: response, error: error, completion)
            }
        }

        currentTask?.resume()
    }

    public func request(url: URL, method: HTTPMethod, parameters: Parameters? = nil, headers: Headers? = nil, _ completion: @escaping (Data?, URLResponse?, NetworkError?) -> Void) {

        guard let request = buildRequest(url: url, method: method, parameters: parameters, headers: headers) else {
            completion(nil, nil, .badRequest)
            return
        }

        currentTask = session.dataTask(with: request) { (data, response, _) in
            DispatchQueue.main.async {

                guard let response = response as? HTTPURLResponse else {
                    return completion(nil, nil, .noResponse)
                }

                guard response.networkError == nil else {
                    return completion(data, response, response.networkError)
                }
                return completion(data, response, nil)
            }
        }

        currentTask?.resume()
    }

    public func buildRequest(url: URL, method: HTTPMethod, parameters: Parameters? = nil, headers: Headers? = nil) -> URLRequest? {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 5.0)
        request.httpMethod = method.rawValue

        if let headers = headers {
            headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        }

        if let parameters = parameters {
            do {
                try encoder.encode(urlRequest: &request, with: parameters)
            } catch {
                return nil
            }
        }

        return request
    }

    func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, _ completion: @escaping (NetworkResponse<T>) -> Void) {

        guard error == nil else {
            return completion(.failure(.unknown))
        }

        guard let response = response as? HTTPURLResponse else {
            return completion(.failure(.noResponse))
        }

        guard response.networkError == nil else {
            return completion(.failure(response.networkError!))
        }

        guard let data = data, let model = try? JSONDecoder().decode(T.self, from: data) else {
            return completion(.failure(.unableToParseData))
        }

        completion(.success(model))
    }
}
