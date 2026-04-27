//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 19.04.2026.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func loadImages() -> Bool
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    var photosCount: Int { get }
    func photo(at index: Int) -> Photo
    func configCell(for index: Int) -> (url: URL?, dateText: String, isLiked: Bool)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    private var imagesListService = ImagesListService()
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateTableView()
            }
        
        _ = loadImages()
    }
    
    func loadImages() -> Bool {
        var result: Bool = true
        imagesListService.fetchPhotosNextPage { error in
            if error != nil {
                result = false
            }
        }
        return result
    }
    
    var photosCount: Int {
        photos.count
    }
    
    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    func configCell(for index: Int) -> (url: URL?, dateText: String, isLiked: Bool) {
        let photo = photos[index]
        let url = URL(string: photo.thumbImageURL)
        
        let dateText: String
        if let createdAt = photo.createdAt {
            dateText = dateFormatter.string(from: createdAt)
        } else {
            dateText = ""
        }
        
        return (url, dateText, photo.isLiked)
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func updateTableView() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
}
