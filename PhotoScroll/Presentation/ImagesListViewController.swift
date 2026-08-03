//
//  ViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 28.07.2026.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, at: indexPath.row)

        return imageListCell
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, at index: Int) {
        guard let image = UIImage(named: photosName[index]) else {
            return
        }

        cell.photoView.image = image
        cell.imageDateLabel.text = dateFormatter.string(from: Date())
        cell.likeButton.setImage(index % 2 == 0 ? UIImage.active : UIImage.noActive, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / image.size.width
        return image.size.height * scale + imageInsets.top + imageInsets.bottom
    }
}
