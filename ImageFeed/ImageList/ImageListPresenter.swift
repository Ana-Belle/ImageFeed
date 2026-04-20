//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 19.04.2026.
//

import UIKit

// MARK: - Presenter Protocol
protocol ImagesListPresenterDelegate: AnyObject {
    func didLoadImages()
    func didUpdateImages(with newIndexPaths: [IndexPath])
    func didUpdateLikeStatus(at indexPath: IndexPath, isLiked: Bool)
    func didFailWithError(_ error: String)
    func presentSingleImage(url: URL)
}

// MARK: - Presenter
final class ImagesListPresenter {
    weak var delegate: ImagesListPresenterDelegate?
    
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    
    var photos: [Photo] {
        imagesListService.photos
    }
    
    init(imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    // MARK: - Public Methods
    func setupServiceObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleImagesListDidChange()
        }
    }
    
    func loadNextPage() {
        imagesListService.fetchPhotosNextPage { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError("Error fetching images: \(error)")
            } else {
                self?.delegate?.didLoadImages()
            }
        }
    }
    
    func toggleLike(for indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        let photo = photos[indexPath.row]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            switch result {
            case .success:
                guard let self = self else { return }
                let updatedPhoto = self.photos[indexPath.row]
                self.delegate?.didUpdateLikeStatus(at: indexPath, isLiked: updatedPhoto.isLiked)
                completion(.success(()))
                
            case .failure(let error):
                self?.delegate?.didFailWithError("Не удалось поставить лайк")
                completion(.failure(error))
            }
        }
    }
    
    func getImageURL(for indexPath: IndexPath) -> URL? {
        let photo = photos[indexPath.row]
        return URL(string: photo.largeImageURL)
    }
    
    func getThumbImageURL(for indexPath: IndexPath) -> URL? {
        let photo = photos[indexPath.row]
        return URL(string: photo.thumbImageURL)
    }
    
    func getPhotoSize(for indexPath: IndexPath) -> CGSize {
        photos[indexPath.row].size
    }
    
    func shouldLoadNextPage(for indexPath: IndexPath) -> Bool {
        indexPath.row == photos.count - 1
    }
    
    func getPhoto(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    
    // MARK: - Private Methods
    private func handleImagesListDidChange() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            delegate?.didUpdateImages(with: indexPaths)
        }
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
