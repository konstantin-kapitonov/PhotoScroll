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
    
	private var photos: [Photo] = []
	private let logger = Logger(label: "PhotoScroll.ImagesListViewController")
	private var presenter: ImagesListPresenterProtocol!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.accessibilityIdentifier = "images_list"
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
		photos = presenter.photos
		presenter.viewDidLoad()
    }

	func configure(_ presenter: ImagesListPresenterProtocol) {
		self.presenter = presenter
		presenter.view = self
	}
    
    // MARK: - Private Methods

	func updateTableViewAnimated() {
		let oldCount = photos.count
		let newCount = presenter.photos.count
		photos = presenter.photos
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
        cell.likeButton.accessibilityIdentifier = photo.isLiked ? "like_button" : "unlike_button"
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

		button.isEnabled = false
		presenter.changeLike(forPhotoAt: indexPath.row) { [weak self] result in
			button.isEnabled = true
			switch result {
			case .success:
				self?.logger.info("Like change completed")
			case .failure(let error):
				self?.logger.error("Like change failed: \(error)")
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
			presenter.fetchNextPageIfNeeded(for: indexPath.row)
		}
	}
}

extension ImagesListViewController: ImagesListViewProtocol { }
