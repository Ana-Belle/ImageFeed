//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 20.04.2026.
//

import XCTest
import Foundation
@testable import ImageFeed

final class ProfileTests: XCTestCase {

    private var viewController: ProfileViewController!
    private var presenter: ProfilePresenterSpy!

    override func setUp() {
        super.setUp()
        viewController = ProfileViewController()
        presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
    }

    func testViewControllerCallsViewDidLoad() {
        // given

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testLogoutCalled() {
        // given

        // when
        presenter.logout()

        // then
        XCTAssertTrue(presenter.logoutCalled)
    }

    override func tearDown() {
        viewController = nil
        presenter = nil
        super.tearDown()
    }

}

