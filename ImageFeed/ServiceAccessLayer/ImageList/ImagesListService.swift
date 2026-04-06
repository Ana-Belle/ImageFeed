//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 05.04.2026.
//
import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}

    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        task?.cancel()

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let token = OAuth2TokenStorage.shared.token else { return }
        guard let request = makeImageListRequest(nextPage: nextPage, token: token) else { return }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            switch result {
            case .success(let result):
                guard let self = self else { return }
                self.lastLoadedPage = nextPage

                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )

            case .failure(let error):
                print("[fetchPhotosNextPage]: Ошибка запроса: \(error.localizedDescription)")
            }
        }

        self.task = task
        task.resume()
    }

    private func makeImageListRequest(nextPage: Int, token: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.defaultBaseURLString + "/photos") else {
            assertionFailure("Ошибка при создании URL")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]

        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

}


