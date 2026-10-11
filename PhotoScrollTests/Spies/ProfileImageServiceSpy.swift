//
//  ProfileImageServiceSpy.swift
//  PhotoScrollTests
//

@testable import PhotoScroll
import Foundation

final class ProfileImageServiceSpy: ProfileImageServiceProtocol {
	var avatarURL: String?
	let profileImageDidChangeNotification = Notification.Name("ProfileImageServiceSpyDidChange")
}
