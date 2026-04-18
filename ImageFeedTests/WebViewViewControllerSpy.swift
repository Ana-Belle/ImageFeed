//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 18.04.2026.
//

import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
