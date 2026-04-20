//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 29.01.2026.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    private let presenter: ImagesListPresenter
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Initialization
    init?(coder: NSCoder, presenter: ImagesListPresenter) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.delegate = self
        setupUI()
        presenter.setupServiceObserver()
        presenter.loadNextPage()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let url = presenter.getImageURL(for: indexPath)
            else {
                assertionFailure("Failed to prepare for \(showSingleImageSegueIdentifier)")
                return
            }
            
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(imageListCell, with: indexPath)
        imageListCell.delegate = self
        
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoSize = presenter.getPhotoSize(for: indexPath)
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photoSize.width
        let cellHeight = photoSize.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if presenter.shouldLoadNextPage(for: indexPath) {
            presenter.loadNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        UIBlockingProgressHUD.show()
        
        presenter.toggleLike(for: indexPath) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                break
            case .failure:
                self?.showErrorAlert(message: "Не удалось поставить лайк")
            }
        }
    }
}

// MARK: - ImagesListPresenterDelegate
extension ImagesListViewController: ImagesListPresenterDelegate {
    func didLoadImages() {
        tableView.reloadData()
    }
    
    func didUpdateImages(with newIndexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        }
    }
    
    func didUpdateLikeStatus(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked)
    }
    
    func didFailWithError(_ error: String) {
        showErrorAlert(message: error)
    }
    
    func presentSingleImage(url: URL) {
        // Can be implemented for direct navigation if needed
    }
}

// MARK: - Private Helper Methods
private extension ImagesListViewController {
    func configureCell(_ cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.getPhoto(at: indexPath)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: presenter.getThumbImageURL(for: indexPath),
            placeholder: UIImage(resource: .stub)
        )
        
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage = photo.isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
