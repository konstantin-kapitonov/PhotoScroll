//
//  SingleImageViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 15.08.2026.
//
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    // MARK: - Constants

    private let minimumZoomScale: CGFloat = 0.1
    private let maximumZoomScale: CGFloat = 1.25

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareButton: UIButton!

    // MARK: - Properties

    private var image: UIImage?
    private var fullImageURL: URL?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureScrollView()
        configureImageView()
        loadFullImage()
    }

    // MARK: - Configuration

    func configure(with image: UIImage, fullImageURL: URL) {
        self.image = image
        self.fullImageURL = fullImageURL

        guard isViewLoaded else { return }
        configureImageView()
        loadFullImage()
    }

    // MARK: - IBActions

    @IBAction private func onBackButtonTap() {
        dismiss(animated: true)
    }

    @IBAction private func onShareButtonTap() {
        guard let image else { return }

        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }

    // MARK: - Private Methods

    private func configureScrollView() {
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
    }

    private func configureImageView() {
        guard let image else { return }

        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: image.size)

        rescaleAndCenterImageInScrollView(image: image)
    }

	private func loadFullImage() {
		guard let fullImageURL else { return }

		UIBlockingProgressHUD.show()
		imageView.contentMode = .center
		imageView.kf.setImage(
			with: fullImageURL,
			placeholder: UIImage.photoStub
		) { [weak self] result in
			UIBlockingProgressHUD.dismiss()

			guard let self else { return }
			switch result {
			case .success(let imageResult):
				self.image = imageResult.image
				self.imageView.contentMode = .scaleAspectFit
				self.configureImageView()
			case .failure:
				self.showError()
			}
		}
	}

	private func showError() {
		let alert = UIAlertController(
			title: "Что-то пошло не так(",
			message: "Не удалось загрузить изображение",
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maximumZoomScale, max(minimumZoomScale, min(hScale, vScale)))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
