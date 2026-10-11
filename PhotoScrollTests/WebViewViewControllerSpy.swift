//
//  WebViewViewControllerSpy.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 11.10.2026.
//

import PhotoScroll
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
	var presenter: PhotoScroll.WebViewPresenterProtocol?

	var loadRequestCalled: Bool = false

	func load(request: URLRequest) {
		loadRequestCalled = true
	}

	func setProgressValue(_ newValue: Float) {

	}

	func setProgressHidden(_ isHidden: Bool) {

	}
}
