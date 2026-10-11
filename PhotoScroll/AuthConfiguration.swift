//
//  Constatnts.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 23.08.2026.
//

enum Constants {
	static let accessKey = "XKq44XXl40Q4CUx-rADMdrt9MVb0vqMdbi8s_nP2QJ0"
	static let secretKey = "QYdpx0y0srJzDAxsTuRo8UZMal69hPV7hH_cj-oQleg"
	static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
	static let accessScope = "public+read_user+write_likes"
	
	static let defaultBaseURLString = "https://api.unsplash.com/"
	static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
	let accessKey: String
	let secretKey: String
	let redirectURI: String
	let accessScope: String
	let defaultBaseURLString: String
	let authURLString: String
	
	static var standard: AuthConfiguration {
		return AuthConfiguration(
			accessKey: Constants.accessKey,
			secretKey: Constants.secretKey,
			redirectURI: Constants.redirectURI,
			accessScope: Constants.accessScope,
			authURLString: Constants.unsplashAuthorizeURLString,
			defaultBaseURLString: Constants.defaultBaseURLString
		)
	}
	
	init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURLString: String) {
		self.accessKey = accessKey
		self.secretKey = secretKey
		self.redirectURI = redirectURI
		self.accessScope = accessScope
		self.defaultBaseURLString = defaultBaseURLString
		self.authURLString = authURLString
	}
}
