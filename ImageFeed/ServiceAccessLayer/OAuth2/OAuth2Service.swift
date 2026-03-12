//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 03.03.2026.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage.shared
    private let decoder = JSONDecoder()

    struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
    }
    
    private init() { }

    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let oAuthTokenRequest = makeOAuthTokenRequest(code: code) else {
            print("Ошибка: не удалось создать запрос")
            return
        }
        
        let task = URLSession.shared.data(for: oAuthTokenRequest) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    print("Ошибка при декодировании данных: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
        
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
    
}
