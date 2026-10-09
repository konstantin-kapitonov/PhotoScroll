//
//  ImagesListService.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 08.10.2026.
//
import Foundation
import CoreGraphics
import Logging

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
	private let logger = Logger(label: "PhotoScroll.ImagesListService")

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

	func changeLike(
		photoId: String,
		isLike: Bool,
		_ completion: @escaping (Result<Void, Error>) -> Void
	) {
		guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
			completion(.failure(NetworkError.invalidRequest))
			return
		}

		let task = urlSession.data(for: request) { [weak self] result in
			guard let self else { return }

			switch result {
			case .success(let data):
				let responseBody = String(data: data, encoding: .utf8) ?? "<non-UTF-8 data>"
				self.logger.info("Like request response: \(responseBody)")

				if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
					let photo = self.photos[index]
					let newPhoto = Photo(
						id: photo.id,
						size: photo.size,
						createdAt: photo.createdAt,
						welcomeDescription: photo.welcomeDescription,
						thumbImageURL: photo.thumbImageURL,
						largeImageURL: photo.largeImageURL,
						isLiked: !photo.isLiked
					)
					self.logger.info(
						"Updating like for photo \(photoId): \(photo.isLiked) -> \(newPhoto.isLiked)"
					)
					self.photos[index] = newPhoto
					NotificationCenter.default.post(
						name: ImagesListService.didChangeNotification,
						object: self
					)
				}
				self.logger.info("Like request completed successfully for photo \(photoId)")
				completion(.success(()))

			case .failure(let error):
				self.logger.error("Like request failed for photo \(photoId): \(error)")
				completion(.failure(error))
			}
		}
		task.resume()
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

	private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
		guard let token = OAuth2TokenStorage.shared.token,
			  let encodedPhotoId = photoId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
			  let url = URL(string: "https://api.unsplash.com/photos/\(encodedPhotoId)/like") else {
			return nil
		}

		var request = URLRequest(url: url)
		request.httpMethod = isLike ? HTTPMethod.delete : HTTPMethod.post
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return request
	}
}
