//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 15.04.2026.
//
import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: CGFloat
    let height: CGFloat
    let likedByUser: Bool
    let description: String?
    let urls: PhotoResultUrls

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}
