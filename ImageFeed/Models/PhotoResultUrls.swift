//
//  PhotoResultUrls.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 15.04.2026.
//
import Foundation

struct PhotoResultUrls: Decodable {
    let thumb: String
    let small: String
    let regular: String
    let full: String
}
