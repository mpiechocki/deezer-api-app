import UIKit

class TrackCell: UITableViewCell {

    static let reuseId = "TrackCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = nil
        diskNumberLabel.text = nil
        titleLabel.text = nil
        durationLabel.text = nil
    }

    // MARK: - Subviews

    let numberLabel = UILabel()
    let diskNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        return label
    }()
    let titleLabel = UILabel()
    let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        return label
    }()
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .lastBaseline
        stackView.spacing = 8.0
        return stackView
    }()

    // MARK: - Private

    private func setupLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        [numberLabel, diskNumberLabel, titleLabel, durationLabel].forEach(stackView.addArrangedSubview)
        numberLabel.setContentHuggingPriority(.required, for: .horizontal)
        numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        diskNumberLabel.setContentHuggingPriority(.required, for: .horizontal)
        diskNumberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        durationLabel.setContentHuggingPriority(.required, for: .horizontal)
        durationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
        ])
    }

}
