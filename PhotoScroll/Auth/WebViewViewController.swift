//
//  WebViewViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 04.09.2026.
//
import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
	var presenter: WebViewPresenterProtocol? { get set }
	func load(request: URLRequest)
	func setProgressValue(_ newValue: Float)
	func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
	var presenter: WebViewPresenterProtocol?
	
    // MARK: - IBOutlets
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    // MARK: - Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.accessibilityIdentifier = "auth_web_view"
        webView.navigationDelegate = self
		presenter?.viewDidLoad()
				
        configureBackButton()
        configureProgressView()
        configureProgressObserver()
    }
    
	// MARK: - Public Methods
	
	func load(request: URLRequest) {
		webView.load(request)
	}
	
	func setProgressValue(_ newValue: Float) {
		progressView.progress = newValue
	}

	func setProgressHidden(_ isHidden: Bool) {
		progressView.isHidden = isHidden
	}
	
    // MARK: - Private Methods
    
    private func configureBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
			image: .backward,
            style: .plain,
            target: self,
            action: #selector(onBackButtonTap)
        )

        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
    }
    
    private func configureProgressView() {
        progressView.progress = 0
        progressView.isHidden = true
    }
    
    private func configureProgressObserver() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: .new
        ) { [weak self] _, _ in
			guard let presenter = self?.presenter,
				  let webView = self?.webView else { return }
			presenter.didUpdateProgressValue(webView.estimatedProgress)
        }
    }
       
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    @objc private func onBackButtonTap() {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
		if let url = navigationAction.request.url {
			return presenter?.code(from: url)
		}
		return nil
    }
}
