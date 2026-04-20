//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 27.03.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(
            identifier: "ImagesListViewController",
            creator: { coder in
                ImagesListViewController(coder: coder, presenter: ImagesListPresenter(imagesListService: ImagesListService()))
            }
        )
        let profileViewController = createProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }

    private func createProfileViewController() -> ProfileViewController {
        let presenter = ProfileViewPresenter(
            profileService: ProfileService.shared,
            profileImageService: ProfileImageService.shared,
            logoutService: ProfileLogoutService.shared
        )

        return ProfileViewController(presenter: presenter)
    }
}
