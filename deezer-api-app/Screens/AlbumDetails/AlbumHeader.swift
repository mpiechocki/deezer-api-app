import UIKit

class AlbumHeader: UIView {

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Subviews

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "arrow.up.arrow.down")?.withRenderingMode(.alwaysOriginal)
        imageView.alpha = 0.3
        return imageView
    }()

    // MARK: - Private

    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
        ])

    }

}
