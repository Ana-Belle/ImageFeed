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
    let width: CGFloat
    let height: CGFloat
    let createdAt: String?
    let description: String?
    let altDescription: String?
    let urls: PhotoResultUrls
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case altDescription = "alt_description"
        case urls
        case likedByUser = "liked_by_user"
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
    let smallImageURL: String
    let regularImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

extension PhotoResult {
    
    func getPhoto() -> Photo {
        var date: Date?
        if let createdAt {
            let dateFormatter = ISO8601DateFormatter()
            date = dateFormatter.date(from: createdAt)
        } else {
            date = nil
        }
        
        return Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: date,
            welcomeDescription: description ?? altDescription,
            thumbImageURL: urls.thumb,
            smallImageURL: urls.small,
            regularImageURL: urls.regular,
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
    
    func fetchPhotosNextPage(completion: @escaping (Error?) -> Void) {
        guard task == nil, let request = request() else { return }
        
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
                        //guard let url = URL(string: photoResult.urls.regular) else { continue }
                        photos.append(photoResult.getPhoto())
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
            }
        }
        task?.resume()
    }
    
    private func request() -> URLRequest? {
        var urlComponents = URLComponents(string: Constants.defaultBaseURLString + "/photos")
        urlComponents?.queryItems = [URLQueryItem(name: "page", value: String(pageNumber))]
        
        guard let url = urlComponents?.url, let token = tokenStorage.token else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
