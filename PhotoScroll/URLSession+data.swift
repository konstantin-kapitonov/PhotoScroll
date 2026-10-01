//
//  URLSession+data.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 07.09.2026.
//
import Foundation
import Logging

private let networkLogger = Logger(label: "PhotoScroll.Networking")

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    networkLogger.error("HTTP request failed with status code \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                networkLogger.error("URL request error: \(error)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                networkLogger.error("Invalid URLSession response")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()

        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    completion(.success(try decoder.decode(T.self, from: data)))
                } catch {
                    let responseBody = String(data: data, encoding: .utf8) ?? "<non-UTF-8 data>"
                    networkLogger.error("Object decoding error: \(String(describing: error)); response data: \(responseBody)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
}
