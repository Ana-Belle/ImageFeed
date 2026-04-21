//
//  ProfileControllerSpy.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 20.04.2026.
//
import XCTest
import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false

    func updateProfileDetails(profile: ImageFeed.Profile) {
        updateProfileDetailsCalled = true
    }

    func updateAvatar(imageUrl: URL) {
        updateAvatarCalled = true
    }
}
