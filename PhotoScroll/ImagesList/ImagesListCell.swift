//
//  ImagesListCell.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 29.07.2026.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var imageDateLabel: UILabel!
    @IBOutlet weak var gradientBackgroundView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Properties
    static let reuseIdentifier = "ImagesListCell"
    private let gradientLayer = CAGradientLayer()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configurePhotoView()
        configureGradientView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientBackgroundView.bounds
    }
    
    // MARK: - Private Methods
    private func configureGradientView() {
        gradientBackgroundView.layer.cornerRadius = 16
        gradientBackgroundView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        gradientBackgroundView.layer.masksToBounds = true

        configureGradientLayer()
    }
    
    private func configureGradientLayer() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.ypBlack.cgColor
        ]

        gradientBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configurePhotoView() {
        photoView.layer.cornerRadius = 16
        photoView.layer.masksToBounds = true
    }
}
