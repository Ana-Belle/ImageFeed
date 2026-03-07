//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 05.03.2026.
//
import Foundation

final class OAuth2TokenStorage {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            return storage.string(forKey: Keys.token.rawValue)
        }
        set {
            if let newValue {
                storage.set(newValue, forKey: Keys.token.rawValue)
            } else {
                storage.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
}


