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
		
		let imagesListViewController = storyboard.instantiateViewController(
			withIdentifier: "ImagesListViewController"
		)
		
		let profileViewController = ProfileViewController()
		profileViewController.tabBarItem = UITabBarItem(
			title: "",
			image: UIImage.profileTabActive,
			selectedImage: nil
		)
		
		self.viewControllers = [imagesListViewController, profileViewController]
	}
}
