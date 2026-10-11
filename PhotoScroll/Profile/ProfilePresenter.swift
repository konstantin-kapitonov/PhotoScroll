//
//  ProfilePresenter.swift
//  PhotoScroll
//

import Foundation

protocol ProfileViewProtocol: AnyObject {
	func updateProfileDetails(profile: Profile)
	func updateAvatar(with url: URL)
	func showSplashScreen()
}

protocol ProfilePresenterProtocol: AnyObject {
	var view: ProfileViewProtocol? { get set }
	func viewDidLoad()
	func didConfirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
	weak var view: ProfileViewProtocol?
	private let profileService: ProfileServiceProtocol
	private let profileImageService: ProfileImageServiceProtocol
	private let profileLogoutService: ProfileLogoutServiceProtocol
	private let notificationCenter: NotificationCenter
	private var observer: NSObjectProtocol?

	init(
		profileService: ProfileServiceProtocol,
		profileImageService: ProfileImageServiceProtocol,
		profileLogoutService: ProfileLogoutServiceProtocol,
		notificationCenter: NotificationCenter = .default
	) {
		self.profileService = profileService
		self.profileImageService = profileImageService
		self.profileLogoutService = profileLogoutService
		self.notificationCenter = notificationCenter
	}

	deinit {
		if let observer {
			notificationCenter.removeObserver(observer)
		}
	}

	func viewDidLoad() {
		guard let profile = profileService.profile else {
			assertionFailure("Profile is missing")
			return
		}
		view?.updateProfileDetails(profile: profile)
		observeProfileImage()
		updateAvatar()
	}

	func didConfirmLogout() {
		profileLogoutService.logout()
		view?.showSplashScreen()
	}

	private func observeProfileImage() {
		guard observer == nil else { return }
		observer = notificationCenter.addObserver(
			forName: profileImageService.profileImageDidChangeNotification,
			object: profileImageService,
			queue: .main
		) { [weak self] _ in
			self?.updateAvatar()
		}
	}

	private func updateAvatar() {
		guard let avatarURL = profileImageService.avatarURL, let url = URL(string: avatarURL) else { return }
		view?.updateAvatar(with: url)
	}
}
