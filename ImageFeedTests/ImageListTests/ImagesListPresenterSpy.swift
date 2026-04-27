//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 21.04.2026.
//

import XCTest
import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var loadImagesCalled: Bool = false
    var photosCountResult: Int = 0

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func loadImages() -> Bool {
        loadImagesCalled = true
        return true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) { }

    var photosCount: Int {
        photosCountResult
    }

    func photo(at index: Int) -> ImageFeed.Photo {
        Photo(id: "", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    }

    func configCell(for index: Int) -> (url: URL?, dateText: String, isLiked: Bool) {
        (nil, "", false)
    }
}
