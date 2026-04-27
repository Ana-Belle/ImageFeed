//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Anastasia Belyakova on 18.04.2026.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()

        webView.buttons["Login"].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        // given
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        // when - Wait for initial cell
        let initialCellExpectation = XCTestExpectation(description: "Initial cell visible")
        let timer1 = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if cell.exists {
                initialCellExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5) { _ in
            timer1.invalidate()
        }

        cell.swipeUp()

        // when - Wait for second cell after scroll
        let secondCellExpectation = XCTestExpectation(description: "Second cell visible after scroll")
        let timer2 = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
            if cellToLike.exists && cellToLike.isHittable {
                secondCellExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5) { _ in
            timer2.invalidate()
        }

        // then - Like actions
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()

        // when - Wait for UI to update after like
        let uiUpdateExpectation = XCTestExpectation(description: "UI updated after like")
        let timer3 = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if cellToLike.exists && cellToLike.isHittable {
                uiUpdateExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5) { _ in
            timer3.invalidate()
        }

        cellToLike.tap()

        // when - Wait for image to load
        let imageExpectation = XCTestExpectation(description: "Image loaded")
        let timer4 = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let image = self.app.scrollViews.images.element(boundBy: 0)
            if image.exists {
                imageExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5) { _ in
            timer4.invalidate()
        }

        // then - Zoom interactions
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        // when - Tap back button
        let navBackButton = app.buttons["nav back button"]
        navBackButton.tap()
    }

    func testProfile() throws {
        // given
        let profileTabButton = app.tabBars.buttons.element(boundBy: 1)

        // when - Wait for tab bar button to be ready
        let tabBarReadyExpectation = XCTestExpectation(description: "Tab bar button is ready")
        let tabBarTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if profileTabButton.exists && profileTabButton.isHittable {
                tabBarReadyExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { _ in
            tabBarTimer.invalidate()
        }

        profileTabButton.tap()

        // then - Wait for profile name to appear
        let profileNameText = app.staticTexts["Anastasia Belyakova"]
        let nameLoadedExpectation = XCTestExpectation(description: "Profile name loaded")
        let nameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if profileNameText.exists {
                nameLoadedExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { _ in
            nameTimer.invalidate()
        }
        XCTAssertTrue(profileNameText.exists)

        // then - Wait for profile login to appear
        let profileLoginText = app.staticTexts["@belanika"]
        let loginLoadedExpectation = XCTestExpectation(description: "Profile login loaded")
        let loginTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if profileLoginText.exists {
                loginLoadedExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { _ in
            loginTimer.invalidate()
        }
        XCTAssertTrue(profileLoginText.exists)

        // when - Exit button
        let exitButton = app.buttons["exit button"]
        let exitButtonReadyExpectation = XCTestExpectation(description: "Exit button ready")
        let exitButtonTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if exitButton.exists && exitButton.isHittable {
                exitButtonReadyExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { _ in
            exitButtonTimer.invalidate()
        }

        exitButton.tap()

        // then - Alert confirmation
        let alert = app.alerts["Пока, пока!"]
        let alertExpectation = XCTestExpectation(description: "Logout alert appears")
        let alertTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if alert.exists {
                alertExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { _ in
            alertTimer.invalidate()
        }

        alert.scrollViews.otherElements.buttons["Да"].tap()
    }
}
