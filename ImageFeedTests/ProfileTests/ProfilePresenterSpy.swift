//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 20.04.2026.
//
import XCTest
import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var logoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func logout() {
        logoutCalled = true
    }
}
