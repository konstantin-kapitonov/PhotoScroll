//
//  ProfileServiceSpy.swift
//  PhotoScrollTests
//

@testable import PhotoScroll

final class ProfileServiceSpy: ProfileServiceProtocol {
	let profile: Profile?

	init(profile: Profile?) {
		self.profile = profile
	}
}
