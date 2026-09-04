//
//  OAuth2Service.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 07.09.2026.
//
import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
	
	private let decoder = JSONDecoder()
    
    private init() { }
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequest))
            }
            return
        }

        let task = URLSession.shared.data(for: request) { [weak decoder] result in
			guard let decoder else { return }
            switch result {
            case .success(let data):
                do {
					let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(responseBody.accessToken))
                } catch {
                    print("OAuth token decoding error: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }

            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("Unsplash service error: HTTP status code \(statusCode)")
                case NetworkError.urlRequestError(let underlyingError):
                    print("OAuth token network error: \(underlyingError)")
                case NetworkError.urlSessionError:
                    print("OAuth token network error: invalid URLSession response")
                default:
                    print("OAuth token request error: \(error)")
                }
                completion(.failure(error))
            }
        }

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
