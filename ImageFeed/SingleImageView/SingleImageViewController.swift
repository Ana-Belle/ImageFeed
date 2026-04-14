//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 15.02.2026.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        showFullImage()
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard imageSize.width != 0 && imageSize.height != 0 else {
            print("Ошибка: ширина или высота изображения равны нулю.")
            return
        }
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        let theoreticalScale = max(hScale, vScale)
        let scale = min(maxZoomScale, max(minZoomScale, theoreticalScale))
        
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: scaledWidth, height: scaledHeight))
        imageView.image = image
        
        scrollView.contentSize = imageView.frame.size
        scrollView.setZoomScale(1, animated: false)
        scrollView.layoutIfNeeded()
        
        let x = (scrollView.contentSize.width - visibleRectSize.width) / 2
        let y = (scrollView.contentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showFullImage() {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так.",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.showFullImage()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
