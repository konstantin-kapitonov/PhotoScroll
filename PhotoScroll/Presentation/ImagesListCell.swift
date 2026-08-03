//
//  ImagesListCell.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 29.07.2026.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var imageDateLabel: UILabel!
    @IBOutlet var gradientBackgroundView: UIView!
    @IBOutlet var likeButton: UIButton!

    private let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        photoView.layer.cornerRadius = 16
        photoView.layer.masksToBounds = true

        gradientBackgroundView.layer.cornerRadius = 16
        gradientBackgroundView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        gradientBackgroundView.layer.masksToBounds = true

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.ypBlack.cgColor
        ]
        gradientBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientBackgroundView.bounds
    }
}
