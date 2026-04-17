//
//  PhotoResult+Mapper.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 15.04.2026.
//
import Foundation

extension PhotoResult {

    func getPhoto(dateFormatter: ISO8601DateFormatter) -> Photo {
        var date: Date?
        if let createdAt {
            date = dateFormatter.date(from: createdAt)
        } else {
            date = nil
        }

        return Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: date,
            welcomeDescription: description,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.full,
            isLiked: likedByUser
        )
    }
}
