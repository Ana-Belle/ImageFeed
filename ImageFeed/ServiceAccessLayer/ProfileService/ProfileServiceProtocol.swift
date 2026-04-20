//
//  ProfileServiceProtocol.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 20.04.2026.
//

// MARK: - Service Protocols
protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

protocol ProfileLogoutServiceProtocol {
    func logout()
}

// MARK: - Service Conformance (Adapters)
extension ProfileService: ProfileServiceProtocol {}

extension ProfileImageService: ProfileImageServiceProtocol {}

extension ProfileLogoutService: ProfileLogoutServiceProtocol {}
