//
//  ViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 28.07.2026.
//

import UIKit
import Kingfisher
import Logging

final class ImagesListViewController: UIViewController {
    //MARK: - Constants
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!

    // MARK: - Properties
    
	private let imagesListService: ImagesListService = .shared
	private var photos: [Photo] = []
	private var imagesListServiceObserver: NSObjectProtocol?
	private let logger = Logger(label: "PhotoScroll.ImagesListViewController")
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
		imagesListServiceObserver = NotificationCenter.default.addObserver(
			forName: ImagesListService.didChangeNotification,
			object: imagesListService,
			queue: .main
		) { [weak self] _ in
			self?.updateTableViewAnimated()
		}
		imagesListService.fetchPhotosNextPage()
    }

	deinit {
		if let imagesListServiceObserver {
			NotificationCenter.default.removeObserver(imagesListServiceObserver)
		}
	}
    
    // MARK: - Private Methods

	func updateTableViewAnimated() {
		let oldCount = photos.count
		let newCount = imagesListService.photos.count
		photos = imagesListService.photos
		if oldCount != newCount {
			tableView.performBatchUpdates {
				let indexPaths = (oldCount..<newCount).map { i in
					IndexPath(row: i, section: 0)
				}
				tableView.insertRows(at: indexPaths, with: .automatic)
			} completion: { _ in }
		} else {
			tableView.reloadData()
		}
	}
    
    private func configCell(for cell: ImagesListCell, at index: Int) {
		let photo = photos[index]
        cell.selectionStyle = .none
		cell.photoView.kf.indicatorType = .activity
		cell.photoView.contentMode = .center
		cell.photoView.kf.setImage(
			with: URL(string: photo.thumbImageURL),
			placeholder: UIImage.photoStub
		) { result in
			if case .success = result {
				cell.photoView.contentMode = .scaleAspectFill
			}
		}
        cell.imageDateLabel.text = photo.createdAt.map(dateFormatter.string)
        cell.likeButton.setImage(photo.isLiked ? UIImage.likeActive : UIImage.likeNoActive, for: .normal)
		cell.likeButton.removeTarget(nil, action: nil, for: .touchUpInside)
		cell.likeButton.addTarget(self, action: #selector(onLikeButtonTap(_:)), for: .touchUpInside)
    }

	@objc private func onLikeButtonTap(_ button: UIButton) {
		let buttonCenter = button.convert(
			CGPoint(x: button.bounds.midX, y: button.bounds.midY),
			to: tableView
		)
		guard let indexPath = tableView.indexPathForRow(at: buttonCenter) else { return }

		let photo = photos[indexPath.row]
		button.isEnabled = false
		imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
			button.isEnabled = true
			switch result {
			case .success:
				self?.logger.info("Like change completed for photo \(photo.id)")
			case .failure(let error):
				self?.logger.error("Like change failed for photo \(photo.id): \(error)")
			}
		}
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

			guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell,
				  let image = cell.photoView.image,
				  let fullImageURL = URL(string: photos[indexPath.row].largeImageURL) else {
				assertionFailure("Image not found")
				return
			}
            viewController.configure(with: image, fullImageURL: fullImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		photos.count
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
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
		let photoSize = photos[indexPath.row].size
		guard photoSize.width > 0 else { return 0 }

        let scale = imageViewWidth / photoSize.width
        return photoSize.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: false)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
	
	func tableView(
	  _ tableView: UITableView,
	  willDisplay cell: UITableViewCell,
	  forRowAt indexPath: IndexPath
	) {
		if indexPath.row == photos.count - 1 {
			imagesListService.fetchPhotosNextPage()
		}
	}
}
