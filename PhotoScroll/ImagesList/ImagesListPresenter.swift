//
//  ImagesListPresenter.swift
//  PhotoScroll
//

import Foundation

protocol ImagesListViewProtocol: AnyObject {
	func updateTableViewAnimated()
}

protocol ImagesListPresenterProtocol: AnyObject {
	var view: ImagesListViewProtocol? { get set }
	var photos: [Photo] { get }
	func viewDidLoad()
	func fetchNextPageIfNeeded(for index: Int)
	func changeLike(forPhotoAt index: Int, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
	weak var view: ImagesListViewProtocol?
	private let imagesListService: ImagesListServiceProtocol
	private let notificationCenter: NotificationCenter
	private var observer: NSObjectProtocol?

	var photos: [Photo] {
		imagesListService.photos
	}

	init(
		imagesListService: ImagesListServiceProtocol,
		notificationCenter: NotificationCenter = .default
	) {
		self.imagesListService = imagesListService
		self.notificationCenter = notificationCenter
	}

	deinit {
		if let observer {
			notificationCenter.removeObserver(observer)
		}
	}

	func viewDidLoad() {
		observePhotos()
		imagesListService.fetchPhotosNextPage()
	}

	func fetchNextPageIfNeeded(for index: Int) {
		if index == photos.count - 1 {
			imagesListService.fetchPhotosNextPage()
		}
	}

	func changeLike(forPhotoAt index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
		guard photos.indices.contains(index) else {
			completion(.failure(NetworkError.invalidRequest))
			return
		}
		let photo = photos[index]
		imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked, completion)
	}

	private func observePhotos() {
		guard observer == nil else { return }
		observer = notificationCenter.addObserver(
			forName: imagesListService.photosDidChangeNotification,
			object: imagesListService,
			queue: .main
		) { [weak self] _ in
			self?.view?.updateTableViewAnimated()
		}
	}
}
