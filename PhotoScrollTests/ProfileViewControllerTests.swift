//
//  ProfileViewControllerTests.swift
//  PhotoScrollTests
//

@testable import PhotoScroll
import XCTest

final class ProfileViewControllerTests: XCTestCase {
	func testViewControllerCallsPresenterOnLoad() {
		let viewController = ProfileViewController()
		let presenter = ProfilePresenterSpy()
		viewController.configure(presenter)

		_ = viewController.view

		XCTAssertTrue(presenter.viewDidLoadCalled)
	}

	func testPresenterUpdatesProfileDetailsOnLoad() {
		let profile = Profile(
			username: "tester",
			name: "Test User",
			loginName: "@tester",
			bio: "Bio"
		)
		let view = ProfileViewSpy()
		let presenter = ProfilePresenter(
			profileService: ProfileServiceSpy(profile: profile),
			profileImageService: ProfileImageServiceSpy(),
			profileLogoutService: ProfileLogoutServiceSpy()
		)
		presenter.view = view

		presenter.viewDidLoad()

		XCTAssertEqual(view.updatedProfile?.username, profile.username)
	}

	func testPresenterLogsOutAndShowsSplashScreen() {
		let logoutService = ProfileLogoutServiceSpy()
		let view = ProfileViewSpy()
		let presenter = ProfilePresenter(
			profileService: ProfileServiceSpy(profile: nil),
			profileImageService: ProfileImageServiceSpy(),
			profileLogoutService: logoutService
		)
		presenter.view = view

		presenter.didConfirmLogout()

		XCTAssertTrue(logoutService.logoutCalled)
		XCTAssertTrue(view.showSplashScreenCalled)
	}
}
