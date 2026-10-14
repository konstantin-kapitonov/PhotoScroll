//
//  TabBarController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 27.09.2026.
//

import UIKit
 
final class TabBarController: UITabBarController {
	override func awakeFromNib() {
		super.awakeFromNib()
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		
		guard let imagesListViewController = storyboard.instantiateViewController(
			withIdentifier: "ImagesListViewController"
		) as? ImagesListViewController else {
			assertionFailure("Unable to create ImagesListViewController")
			return
		}
		imagesListViewController.configure(
			ImagesListPresenter(imagesListService: ImagesListService.shared)
		)
		
		let profileViewController = ProfileViewController()
		profileViewController.configure(
			ProfilePresenter(
				profileService: ProfileService.shared,
				profileImageService: ProfileImageService.shared,
				profileLogoutService: ProfileLogoutService.shared
			)
		)
		profileViewController.tabBarItem = UITabBarItem(
			title: "",
			image: UIImage.profileTabActive,
			selectedImage: nil
		)
		
		self.viewControllers = [imagesListViewController, profileViewController]
	}
}
