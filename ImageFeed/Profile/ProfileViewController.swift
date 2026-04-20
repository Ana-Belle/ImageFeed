//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Anastasia Belyakova on 11.02.2026.
//
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - UI Elements
    private var avatarImageView: UIImageView?
    private var nameLabel: UILabel?
    private var loginNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    
    // MARK: - Dependencies
    private let presenter: ProfileViewPresenter
    
    // MARK: - Initialization
    init(presenter: ProfileViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.delegate = self
        setupUI()
        presenter.setupProfileImageObserver()
        presenter.loadProfile()
        presenter.loadAvatar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .ypBlackIOS
        setupAvatarImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupExitButton()
    }
    
    private func setupAvatarImageView() {
        let profileImage = UIImage(resource: .placeholder)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        avatarImageView = UIImageView(image: profileImage)
        guard let avatarImageView else { return }
        avatarImageView.tintColor = .ypGrayIOS
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel = UILabel()
        guard let nameLabel else { return }
        nameLabel.text = "Имя не указано"
        nameLabel.textColor = .ypWhiteIOS
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        view.addSubview(nameLabel)
        
        guard let avatarImageView else { return }
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupLoginNameLabel() {
        loginNameLabel = UILabel()
        guard let loginNameLabel else { return }
        loginNameLabel.text = "@неизвестный_пользователь"
        loginNameLabel.textColor = .ypGrayIOS
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        guard let nameLabel else { return }
        
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Профиль не заполнен"
        descriptionLabel.textColor = .ypWhiteIOS
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        guard let loginNameLabel else { return }
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
        
        self.descriptionLabel = descriptionLabel
    }
    
    private func setupExitButton() {
        let exitButton = UIButton.systemButton(
            with: UIImage(resource: .exitButton),
            target: self,
            action: #selector(didTapExitButton)
        )
        exitButton.tintColor = .ypRedIOS
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.accessibilityIdentifier = "exit button"
        view.addSubview(exitButton)
        
        guard let avatarImageView else { return }
        
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - User Actions
    @objc private func didTapExitButton() {
        presenter.showLogoutConfirmation()
    }
}

// MARK: - ProfileViewPresenterDelegate
extension ProfileViewController: ProfileViewPresenterDelegate {
    func presentProfile(_ profile: Profile) {
        updateProfileDetails(profile: profile)
    }
    
    func presentAvatar(url: URL) {
        updateAvatar(url: url)
    }
    
    func presentLogoutAlert(confirmHandler: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            confirmHandler()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Private UI Update Methods
    private func updateProfileDetails(profile: Profile) {
        nameLabel?.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel?.text = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        descriptionLabel?.text = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
    }
    
    private func updateAvatar(url: URL) {
        let placeholderImage = UIImage(resource: .placeholder)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        guard let avatarImageView else { return }
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        ) { result in
            switch result {
            case .success(let value):
                print("Image loaded: \(value.cacheType)")
            case .failure(let error):
                print("Image loading error: \(error)")
            }
        }
    }
}
