//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 19.04.2026.
//

import UIKit
import Kingfisher

// MARK: - Presenter Protocol
protocol ProfileViewPresenterDelegate: AnyObject {
    func presentProfile(_ profile: Profile)
    func presentAvatar(url: URL)
    func presentLogoutAlert(confirmHandler: @escaping () -> Void)
}

// MARK: - Presenter
final class ProfileViewPresenter {
    weak var delegate: ProfileViewPresenterDelegate?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileServiceProtocol,
        profileImageService: ProfileImageServiceProtocol,
        logoutService: ProfileLogoutServiceProtocol
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    // MARK: - Public Methods
    func loadProfile() {
        guard let profile = profileService.profile else { return }
        delegate?.presentProfile(profile)
    }
    
    func loadAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let imageUrl = URL(string: profileImageURL) else { return }
        delegate?.presentAvatar(url: imageUrl)
    }
    
    func setupProfileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadAvatar()
            }
    }
    
    func showLogoutConfirmation() {
        delegate?.presentLogoutAlert { [weak self] in
            self?.logout()
        }
    }
    
    func logout() {
        logoutService.logout()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
