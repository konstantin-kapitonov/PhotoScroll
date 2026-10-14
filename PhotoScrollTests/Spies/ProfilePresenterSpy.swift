//
//  ProfilePresenterSpy.swift
//  PhotoScrollTests
//

@testable import PhotoScroll

final class ProfilePresenterSpy: ProfilePresenterProtocol {
	weak var view: ProfileViewProtocol?
	var viewDidLoadCalled = false

	func viewDidLoad() { viewDidLoadCalled = true }
	func didConfirmLogout() { }
}
