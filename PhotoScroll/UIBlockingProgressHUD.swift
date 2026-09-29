//
//  UIBlockingProgressHUD.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 27.09.2026.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
	private static var window: UIWindow? {
		UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap(\.windows)
			.first(where: \.isKeyWindow)
	}
	
	static func show() {
		window?.isUserInteractionEnabled = false
		ProgressHUD.animate()
	}
	
	static func dismiss() {
		window?.isUserInteractionEnabled = true
		ProgressHUD.dismiss()
	} 
}

