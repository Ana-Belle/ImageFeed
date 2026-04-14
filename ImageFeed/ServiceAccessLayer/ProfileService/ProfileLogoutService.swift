//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 13.04.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanAppData()
        switchToSplashViewController()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanAppData() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.clean()
        ProfileImageService.shared.clean()
        let imagesListService = ImagesListService()
        imagesListService.clean()
    }
    
    private func switchToSplashViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            assertionFailure("Invalid window configuration")
            return
        }
        guard let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}

