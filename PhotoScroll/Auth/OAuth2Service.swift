//
//  OAuth2Service.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 07.09.2026.
//
import Foundation
import Logging

final class OAuth2Service {
    static let shared = OAuth2Service()
	
    private let logger = Logger(label: "PhotoScroll.OAuth2Service")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private var activeRequestID: UUID?
    
    private init() { }
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        if lastCode == code {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        task?.cancel()

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let requestID = UUID()
        activeRequestID = requestID
        lastCode = code

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
			guard let self, self.activeRequestID == requestID else { return }

            self.task = nil
            self.lastCode = nil
            self.activeRequestID = nil

            switch result {
            case .success(let responseBody):
                completion(.success(responseBody.accessToken))

            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    logger.error("Unsplash service error: HTTP status code \(statusCode)")
                case NetworkError.urlRequestError(let underlyingError):
                    logger.error("OAuth token network error: \(underlyingError)")
                case NetworkError.urlSessionError:
                    logger.error("OAuth token network error: invalid URLSession response")
                default:
                    logger.error("OAuth token request error: \(error)")
                }
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
		request.httpMethod = HTTPMethod.post
        return request
    }
}

private struct OAuthTokenResponseBody: Decodable {
    let accessToken: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
