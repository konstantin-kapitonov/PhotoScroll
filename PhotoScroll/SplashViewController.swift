//
//  SplashViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 09.09.2026.
//

import UIKit
import Logging

final class SplashViewController: UIViewController {
    // MARK: - Properties
    
    private let authViewControllerIdentifier = "AuthViewController"
    private let tabBarViewControllerIdentifier = "TabBarViewController"
	
	private let tokenStorage = OAuth2TokenStorage.shared
	private let profileService = ProfileService.shared
    private let logger = Logger(label: "PhotoScroll.SplashViewController")
	private let profileImageService = ProfileImageService.shared

    private let logoImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage.splashScreenLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = tokenStorage.token else {
            showAuthenticationScreen()
            return
        }

        fetchProfile(token: token)
    }
}

// MARK: - Navigation

extension SplashViewController {
    private func showAuthenticationScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: authViewControllerIdentifier
        ) as? AuthViewController else {
            assertionFailure("Failed to instantiate \(authViewControllerIdentifier)")
            return
        }

        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }) else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: tabBarViewControllerIdentifier)
           
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)

        guard let token = tokenStorage.token else {
            assertionFailure("OAuth token is missing")
            return
        }

        fetchProfile(token: token)
    }
	
	private func fetchProfile(token: String) {
		UIBlockingProgressHUD.show()
		profileService.fetchProfile(token: token) { [weak self] result in
			UIBlockingProgressHUD.dismiss()
			
			guard let self = self else { return }
			
			switch result {
			case .success(let profile):
				self.switchToTabBarController()
				self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
				
			case .failure(let error):
				self.logger.error("Profile request error: \(error)")
				break
			}
		}
	}
}
