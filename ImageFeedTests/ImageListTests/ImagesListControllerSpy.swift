//
//  ImagesListControllerSpy.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 21.04.2026.
//

import XCTest
import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled: Bool = false
    var showErrorAlertCalled: Bool = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func showErrorAlert() {
        showErrorAlertCalled = true
    }
}

