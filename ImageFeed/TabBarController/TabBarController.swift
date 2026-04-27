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
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            print("ViewController с ID 'ImagesListViewController' не найден")
            return
        }
        navigationController?.pushViewController(imagesListViewController, animated: true)

        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(imagesListPresenter)

        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
