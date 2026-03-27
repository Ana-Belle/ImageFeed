//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 03.03.2026.
//

import Foundation

private enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

private enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage.shared
    //private let decoder = JSONDecoder()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    /*struct OAuthTokenResponseBody: Decodable {
     let access_token: String
     }*/
    
    struct OAuthTokenResponseBody: Codable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
    
    private(set) var authToken: String? {
        get {
            return tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        }
    }
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {                               
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let oAuthTokenRequest = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("Ошибка: не удалось создать запрос")
            return
        }
        
        let task = urlSession.objectTask(for: oAuthTokenRequest) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken // сохраняем в свойство
                    completion(.success(authToken)) // возвращаем наружу
                    
                    self.task = nil
                    self.lastCode = nil
                    
                case .failure(let error):
                    print("[fetchOAuthToken]: Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error)) // ошибка
                    
                    self.task = nil
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
        
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Ошибка при создании URL")
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
