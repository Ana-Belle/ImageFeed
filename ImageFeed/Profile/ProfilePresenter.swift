//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 19.04.2026.
//
import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        if let profile = ProfileService.shared.profile {
            view?.updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        view?.updateAvatar(imageUrl: url)
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
    }
}
