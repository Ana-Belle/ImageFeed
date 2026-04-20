//
//  ImagesListServiceProtocol.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 20.04.2026.
//

// MARK: - Service Protocol
protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage(completion: @escaping (Error?) -> Void)
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - Service Conformance (Adapter)
extension ImagesListService: ImagesListServiceProtocol {}
