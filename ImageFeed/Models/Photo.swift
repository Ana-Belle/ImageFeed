//
//  Photo.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 15.04.2026.
//
import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
