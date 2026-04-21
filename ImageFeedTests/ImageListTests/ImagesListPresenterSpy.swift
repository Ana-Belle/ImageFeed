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
    
    func photosCount() -> Int {
        return photosCountResult
    }
    
    func photo(at index: Int) -> ImageFeed.Photo {
        fatalError("")
    }
    
    func configCell(for index: Int) -> (url: URL?, dateText: String, isLiked: Bool) {
        fatalError("")
    }
}
