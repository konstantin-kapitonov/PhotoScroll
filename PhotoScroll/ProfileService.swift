//
//  ProfileService.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 27.09.2026.
//

import Foundation
import Logging

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
	let username: String
	let name: String
	let loginName: String
	let bio: String
}

final class ProfileService {
    static let shared = ProfileService()

    private(set) var profile: Profile?
    private let logger = Logger(label: "PhotoScroll.ProfileService")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private var activeRequestID: UUID?

    private init() { }

    func fetchProfile(
        token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        if lastToken == token {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let requestID = UUID()
        activeRequestID = requestID
        lastToken = token

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self, self.activeRequestID == requestID else { return }

            self.task = nil
            self.lastToken = nil
            self.activeRequestID = nil

            switch result {
            case .success(let profileResult):
                let name = [profileResult.firstName, profileResult.lastName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                let profile = Profile(
                    username: profileResult.username,
                    name: name.isEmpty ? profileResult.username : name,
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio ?? ""
                )
                self.profile = profile
                completion(.success(profile))

            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    logger.error("Unsplash service error: HTTP status code \(statusCode)")
                case NetworkError.urlRequestError(let underlyingError):
                    logger.error("Profile network error: \(underlyingError)")
                case NetworkError.urlSessionError:
                    logger.error("Profile network error: invalid URLSession response")
                default:
                    logger.error("Profile request error: \(error)")
                }
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
