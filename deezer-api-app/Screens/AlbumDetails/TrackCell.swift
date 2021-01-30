import UIKit

class TrackCell: UITableViewCell {

    static let reuseId = "TrackCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Subviews

    let numberLabel = UILabel()
    let titleLabel = UILabel()
    let durationLabel = UILabel()
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8.0
        return stackView
    }()

    // MARK: - Private

    private func setupLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        [numberLabel, titleLabel, durationLabel].forEach(stackView.addArrangedSubview)
        numberLabel.setContentHuggingPriority(.required, for: .horizontal)
        durationLabel.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4.0),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4.0),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0)
        ])
    }

}
