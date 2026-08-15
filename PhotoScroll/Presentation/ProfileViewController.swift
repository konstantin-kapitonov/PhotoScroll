//
//  ProfileViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 11.08.2026.
//
import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private var imageView = UIImageView()
    private var exitButton = UIButton()
    private var nameLabel = UILabel()
    private var userNameLabel = UILabel()
    private var descriptionLabel = UILabel()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        configureProfileImageView()
        configureExitButton()
        configureNameLabel()
        configureUserNameLable()
        configureDescriptionLabel()
    }
    
    // MARK: - Private Methods
    
    private func configureProfileImageView() {
        imageView.image = .profile
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        [
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ].forEach { $0.isActive = true }
        
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
    }
    
    private func configureExitButton() {
        exitButton.setImage(.exit, for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)

        [
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ].forEach { $0.isActive = true }
        
        exitButton.addTarget(
            self,
            action: #selector(onExitButtonTap),
            for: .touchUpInside
        )
    }
    
    private func configureNameLabel() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        [
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
        ].forEach { $0.isActive = true }
    }
    
    private func configureUserNameLable() {
        userNameLabel.text = "@ekaterina_nov"
        userNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        userNameLabel.textColor = .ypGray
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNameLabel)
        
        [
            userNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
        ].forEach { $0.isActive = true }
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        [
            descriptionLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
        ].forEach { $0.isActive = true }
    }
    
    @objc private func onExitButtonTap(_ sender: UIButton) {
        
    }
}
