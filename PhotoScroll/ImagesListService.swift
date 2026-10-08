//
//  ImagesListService.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 08.10.2026.
//
import Foundation
import CoreGraphics

struct Photo {
	let id: String
	let size: CGSize
	let createdAt: Date?
	let welcomeDescription: String?
	let thumbImageURL: String
	let largeImageURL: String
	let isLiked: Bool
}

struct PhotoResult: Decodable {
	let id: String
	let createdAt: String
	let width: Int
	let height: Int
	let description: String?
	let likedByUser: Bool
	let urls: UrlsResult

	private enum CodingKeys: String, CodingKey {
		case id
		case createdAt = "created_at"
		case width
		case height
		case description
		case likedByUser = "liked_by_user"
		case urls
	}
}

struct UrlsResult: Decodable {
	let thumb: String
	let full: String
}

final class ImagesListService {
	static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
	static let shared = ImagesListService()

	private(set) var photos: [Photo] = []

	private var lastLoadedPage: Int?
	private var task: URLSessionTask?
	private let urlSession = URLSession.shared
	private let dateFormatter = ISO8601DateFormatter()

	private init() { }

	func fetchPhotosNextPage() {
		guard task == nil,
			  let request = makePhotosRequest() else {
			return
		}

		let nextPage = (lastLoadedPage ?? 0) + 1
		task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
			guard let self else { return }
			self.task = nil

			switch result {
			case .success(let photoResults):
				let newPhotos = photoResults.map { photoResult in
					Photo(
						id: photoResult.id,
						size:
							CGSize(width: photoResult.width, height: photoResult.height),
						createdAt: self.dateFormatter.date(from: photoResult.createdAt),
						welcomeDescription: photoResult.description,
						thumbImageURL: photoResult.urls.thumb,
						largeImageURL: photoResult.urls.full,
						isLiked: photoResult.likedByUser
					)
				}

				DispatchQueue.main.async {
					self.photos.append(contentsOf: newPhotos)
					self.lastLoadedPage = nextPage
					NotificationCenter.default.post(
						name: ImagesListService.didChangeNotification,
						object: self
					)
				}

			case .failure:
				break
			}
		}
		task?.resume()
	}

	private func makePhotosRequest() -> URLRequest? {
		guard let token = OAuth2TokenStorage.shared.token,
			  var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
			return nil
		}

		let nextPage = (lastLoadedPage ?? 0) + 1
		urlComponents.queryItems = [
			URLQueryItem(name: "page", value: String(nextPage)),
			URLQueryItem(name: "per_page", value: "10")
		]

		guard let url = urlComponents.url else { return nil }

		var request = URLRequest(url: url)
		request.httpMethod = HTTPMethod.get
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return request
	}
}
