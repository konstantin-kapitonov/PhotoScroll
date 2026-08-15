//
//  SingleImageViewController.swift
//  PhotoScroll
//
//  Created by Капитонов Константин Евгеньевич on 15.08.2026.
//
import UIKit

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureScrollView()
        configureImageView()
    }

    // MARK: - Configuration

    func configure(with image: UIImage) {
        self.image = image

        guard isViewLoaded else { return }
        configureImageView()
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
        imageView.frame.size = image.size

        rescaleAndCenterImageInScrollView(image: image)
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
