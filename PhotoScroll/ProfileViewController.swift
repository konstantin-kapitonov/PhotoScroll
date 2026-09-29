//
//  ProfileViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 11.08.2026.
//
import UIKit
import Kingfisher
import Logging

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private lazy var imageView = UIImageView()
    private lazy var exitButton = UIButton()
    private lazy var nameLabel = UILabel()
    private lazy var userNameLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
	
	private let logger = Logger(label: "PhotoScroll.ProfileViewController")
	private let profileService = ProfileService.shared
	private let profileImageService = ProfileImageService.shared
	
	private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        configureProfileImageView()
        configureExitButton()
        configureNameLabel()
        configureUserNameLabel()
        configureDescriptionLabel()

        guard let profile = profileService.profile else {
            assertionFailure("Profile is missing")
            return
        }

        updateProfileDetails(profile: profile)
		
		profileImageServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ProfileImageService.didChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard let self else { return }
				self.updateAvatar()
			}
		updateAvatar()
	}
    
    // MARK: - Private Methods
    
    private func configureProfileImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        [
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ].forEach { $0.isActive = true }
    }
    
    private func configureExitButton() {
        exitButton.setImage(.exit, for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)

        [
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ].forEach { $0.isActive = true }
        
        exitButton.addTarget(
            self,
            action: #selector(onExitButtonTap),
            for: .touchUpInside
        )
    }
    
    private func configureNameLabel() {
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        [
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
        ].forEach { $0.isActive = true }
    }
    
    private func configureUserNameLabel() {
        userNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        userNameLabel.textColor = .ypGray
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNameLabel)
        
        [
            userNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
        ].forEach { $0.isActive = true }
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        [
            descriptionLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
        ].forEach { $0.isActive = true }
    }

    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        userNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
	
	private func updateAvatar() {
		guard
			let profileImageURL = profileImageService.avatarURL,
			let url = URL(string: profileImageURL)
		else { return }
		let processor = RoundCornerImageProcessor(radius: .widthFraction(0.5))
		imageView.kf.indicatorType = .activity
		imageView.kf.setImage(
			with: url,
			placeholder: UIImage.avatarStub,
			options: [
				.processor(processor),
				.cacheOriginalImage,
				.cacheOriginalImage,
				.forceRefresh
			]
		) { [weak self] result in
			switch result {
			case .success(let value):
				self?.logger.info("Avatar cache type: \(value.cacheType)")
				self?.logger.info("Avatar source: \(value.source)")
			case .failure(let error):
				self?.logger.error("Failed to load avatar: \(error)")
			}
		}
	}

    @objc private func onExitButtonTap(_ sender: UIButton) {
        
    }
}
