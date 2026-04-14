//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 05.04.2026.
//
import Foundation

enum ImagesListServiceError: Error {
    case corruptedData
}

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

struct PhotoResultUrls: Decodable {
    let thumb: String
    let small: String
    let regular: String
    let full: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

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

class ImagesListService {
    private let tokenStorage = OAuth2TokenStorage.shared
    private let decoder = JSONDecoder()
    
    private var pageNumber: Int = 1
    private var task: URLSessionTask?
    
    var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    func fetchPhotosNextPage(completion: @escaping (Error?) -> Void) {
        guard task == nil else { return }
        
        guard let request = makeFetchPhotosNextPageRequest()
        else {
            print("[fetchPhotosNextPage(ImagesListService)]: Ошибка создания запроса")
            return
        }
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            let complentionOnMainQueue: (Error?) -> Void = { error in
                DispatchQueue.main.async {
                    completion(error)
                }
            }
            
            task = nil
            if let error {
                DispatchQueue.main.async {
                    complentionOnMainQueue(error)
                }
            }
            
            if let data {
                do {
                    let photoResults = try decoder.decode([PhotoResult].self, from: data)
                    for photoResult in photoResults {
                        photos.append(photoResult.getPhoto(dateFormatter: dateFormatter))
                    }
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                    
                    pageNumber += 1
                    
                    complentionOnMainQueue(nil)
                } catch {
                    complentionOnMainQueue(error)
                }
            } else {
                complentionOnMainQueue(ImagesListServiceError.corruptedData)
                print("[fetchPhotosNextPage(ImagesListService)]: Ошибка запроса")
            }
        }
        task?.resume()
    }
    
    private func makeFetchPhotosNextPageRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: Constants.defaultBaseURLString + "/photos")
        urlComponents?.queryItems = [URLQueryItem(name: "page", value: String(pageNumber))]
        
        guard let url = urlComponents?.url, let token = tokenStorage.token else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard task == nil, let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike) else { return }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index].isLiked.toggle()
                }
                completion(.success(()))
            case .failure(let error):
                print("[changeLike(ImagesListService)]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
        }
        
        self.task = task
        task.resume()
        
    }
    
    private func makeChangeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let token = tokenStorage.token else { return nil }
        let urlString = Constants.defaultBaseURLString + "/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else { return nil  }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clean() {
        photos = []
    }
}
