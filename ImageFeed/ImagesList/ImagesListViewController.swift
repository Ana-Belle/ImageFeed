//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 29.01.2026.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showErrorAlert()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter?.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Failed to prepare for \(showSingleImageSegueIdentifier)")
                return
            }
            
            if let urlString = presenter?.photo(at: indexPath.row).largeImageURL, let url = URL(string: urlString) {
                viewController.imageURL = url
            }
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        imageListCell.delegate = self
        
        return imageListCell
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let config = presenter?.configCell(for: indexPath.row) else { return }
        
        cell.cellImage.kf.indicatorType = .activity
        if let url = config.url {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(resource: .stub)
            )
        }
        
        cell.dateLabel.text = config.dateText
        cell.setIsLiked(config.isLiked)
    }
    
    private func loadImages() {
        guard let presenter else { return }
        if presenter.loadImages()  {
            self.tableView.reloadData()
        } else {
            print("Error fetching images")
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath.row) else { return 0 }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let imageCount = presenter?.photosCount ?? 0

        if indexPath.row == imageCount - 1 {
            loadImages()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell), let presenter else { return }
        let photo = presenter.photo(at: indexPath.row)
        
        UIBlockingProgressHUD.show()
        
        presenter.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                cell.setIsLiked(presenter.photo(at: indexPath.row).isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
                return
            }
        }
    }
    
}
