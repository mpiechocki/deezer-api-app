import Combine
import UIKit

class AlbumCell: UICollectionViewCell {

    static let reuseId = "AlbumCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) { nil }

    var cancellables = Set<AnyCancellable>()

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        imageView.alpha = 0.3
        cancellables = Set<AnyCancellable>()
    }

    // MARK: - Subviews

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.up.arrow.down")?.withRenderingMode(.alwaysOriginal)
        imageView.alpha = 0.3
        return imageView
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Private

    private func setupLayout() {
        [imageView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4.0),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0)
        ])

        titleLabel.setContentHuggingPriority(.required, for: .vertical)
    }

}
