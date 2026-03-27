//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 05.03.2026.
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() { }

    private enum Keys: String {
        case token
    }

    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
}


