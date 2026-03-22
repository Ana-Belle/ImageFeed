//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 19.03.2026.
//
import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.windows.first
        }
        return nil
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
}
