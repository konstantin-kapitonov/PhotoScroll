//
//  ImagesListViewControllerTests.swift
//  PhotoScrollTests
//

@testable import PhotoScroll
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
	func testImagesListViewControllerCallsPresenterOnLoad() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let viewController = storyboard.instantiateViewController(
			withIdentifier: "ImagesListViewController"
		) as! ImagesListViewController
		let presenter = ImagesListPresenterSpy()
		viewController.configure(presenter)

		_ = viewController.view

		XCTAssertTrue(presenter.viewDidLoadCalled)
	}

	func testImagesListPresenterFetchesFirstPageOnLoad() {
		let service = ImagesListServiceSpy()
		let presenter = ImagesListPresenter(imagesListService: service)

		presenter.viewDidLoad()

		XCTAssertTrue(service.fetchPhotosNextPageCalled)
	}

}
