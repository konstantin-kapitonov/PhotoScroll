//
//  ProfileImageService.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 27.09.2026.
//

import Foundation
import Logging

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }

    struct ProfileImage: Codable {
        let small: String
		let medium: String
		let large: String
    }
}

final class ProfileImageService {
	static let didChangeNotification = Notification.Name( "ProfileImageProviderDidChange")

	
    static let shared = ProfileImageService()

    private(set) var avatarURL: String?

    private let logger = Logger(label: "PhotoScroll.ProfileImageService")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var activeRequestID: UUID?

    private init() { }

    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        task?.cancel()

        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let requestID = UUID()
        activeRequestID = requestID

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self, self.activeRequestID == requestID else { return }

            self.task = nil
            self.activeRequestID = nil

            switch result {
            case .success(let user):
				let url = user.profileImage.large
                self.avatarURL = url
                completion(.success(url))
				NotificationCenter.default
					.post(
						name: ProfileImageService.didChangeNotification,
						object: self,
						userInfo: ["URL": url])

            case .failure(let error):
                logger.error("Profile image request error: \(error)")
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.unsplash.com/users/\(encodedUsername)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        return request
    }
}
