//
//  ProfileViewSpy.swift
//  PhotoScrollTests
//

@testable import PhotoScroll
import Foundation

final class ProfileViewSpy: ProfileViewProtocol {
	var updatedProfile: Profile?
	var showSplashScreenCalled = false

	func updateProfileDetails(profile: Profile) { updatedProfile = profile }
	func updateAvatar(with url: URL) { }
	func showSplashScreen() { showSplashScreenCalled = true }
}
