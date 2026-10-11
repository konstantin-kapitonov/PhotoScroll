//
//  ImagesListPresenterSpy.swift
//  PhotoScrollTests
//

@testable import PhotoScroll

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
	weak var view: ImagesListViewProtocol?
	var photos: [Photo] = []
	var viewDidLoadCalled = false

	func viewDidLoad() { viewDidLoadCalled = true }
	func fetchNextPageIfNeeded(for index: Int) { }
	func changeLike(forPhotoAt index: Int, completion: @escaping (Result<Void, Error>) -> Void) { }
}
