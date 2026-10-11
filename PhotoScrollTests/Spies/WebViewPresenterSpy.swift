//
//  WebViewPresenterSpy.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 11.10.2026.
//

import PhotoScroll
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
	var viewDidLoadCalled: Bool = false
	var view: WebViewViewControllerProtocol?
	
	func viewDidLoad() {
		viewDidLoadCalled = true
	}
	
	func didUpdateProgressValue(_ newValue: Double) {
	
	}
	
	func code(from url: URL) -> String? {
		return nil
	}
}
