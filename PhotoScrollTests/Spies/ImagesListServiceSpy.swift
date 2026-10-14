//
//  ImagesListServiceSpy.swift
//  PhotoScrollTests
//

@testable import PhotoScroll
import Foundation

final class ImagesListServiceSpy: ImagesListServiceProtocol {
	var photos: [Photo] = []
	let photosDidChangeNotification = Notification.Name("ImagesListServiceSpyDidChange")
	var fetchPhotosNextPageCalled = false

	func fetchPhotosNextPage() { fetchPhotosNextPageCalled = true }
	func changeLike(
		photoId: String,
		isLike: Bool,
		_ completion: @escaping (Result<Void, Error>) -> Void
	) { }
}
