//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 03.03.2026.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    
    struct OAuthTokenResponseBody: Decodable {
        let access_token: String
        let token_type: String
        let scope: String
        let created_at: Int
    }
    
    private init() { }
    
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
        request.httpMethod = "POST"
        return request
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
                    self.tokenStorage.token = response.access_token
                    completion(.success(response.access_token))
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
}
