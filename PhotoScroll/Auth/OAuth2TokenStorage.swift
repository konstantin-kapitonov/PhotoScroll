//
//  OAuth2TokenStorage.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 09.09.2026.
//

import Foundation

final class OAuth2TokenStorage {
	static let shared = OAuth2TokenStorage()
	
	private let tokenKey = "bearerToken"
	
	var token: String? {
		get {
			UserDefaults.standard.string(forKey: tokenKey)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: tokenKey)
		}
	}
	
	private init() { }
}
