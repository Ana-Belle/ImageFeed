//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 20.04.2026.
//

import XCTest
import Foundation
@testable import ImageFeed


final class ImagesListTests: XCTestCase {
    
    private var viewController: ImagesListViewController!
    private var presenter: ImagesListPresenterSpy!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController
        presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
    }
    
    func testViewControllerCallsViewDidLoad() {
        // given
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadImages() {
        // given
        
        // when
        presenter.loadImages()
        
        // then
        XCTAssertTrue(presenter.loadImagesCalled)
    }
    
    override func tearDown() {
        viewController = nil
        presenter = nil
        super.tearDown()
    }
}
