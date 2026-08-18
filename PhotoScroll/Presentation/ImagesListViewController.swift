//
//  ViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 28.07.2026.
//

import UIKit

final class ImagesListViewController: UIViewController {
    //MARK: - Constants
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!

    // MARK: - Properties
    
    private let photosName = (0..<20).map { "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Private Methods
    
    private func configCell(for cell: ImagesListCell, at index: Int) {
        guard let image = UIImage(named: photosName[index]) else {
            return
        }
        
        cell.selectionStyle = .none
        cell.photoView.image = image
        cell.imageDateLabel.text = dateFormatter.string(from: Date())
        cell.likeButton.setImage(index % 2 == 0 ? UIImage.likeActive : UIImage.likeNoActive, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            guard let image = UIImage(named: photosName[indexPath.row]) else {
                assertionFailure("Image not found")
                return
            }
            viewController.configure(with: image)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource

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

// MARK: - UITableViewDelegate

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: false)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}
