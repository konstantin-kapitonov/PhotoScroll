//
//  AuthViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 04.09.2026.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak private var authButton: UIButton!
    
    // MARK: - Properties
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
	private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureAuthButton()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureAuthButton() {
        authButton.layer.cornerRadius = 16
        authButton.layer.masksToBounds = true
    }

    private func showLoginErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.navigationController?.popViewController(animated: true)
		
		// Показываем индикатор загрузки и блокируем пользовательское взаимодействие
		UIBlockingProgressHUD.show()
		
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
			// Скрываем индикатор загрузки
			UIBlockingProgressHUD.dismiss()
			
            switch result {
            case .success(let token):
                guard let self else { return }
                self.oauth2TokenStorage.token = token
                self.delegate?.didAuthenticate(self)
            case .failure:
                self?.showLoginErrorAlert()
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}
