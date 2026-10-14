//
//  ProfileLogoutServiceSpy.swift
//  PhotoScrollTests
//

@testable import PhotoScroll

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
	var logoutCalled = false

	func logout() { logoutCalled = true }
}
