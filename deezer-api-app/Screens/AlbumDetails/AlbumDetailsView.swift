import UIKit

class AlbumDetailsView: UIView {

    init() {
        super.init(frame: .zero)
        backgroundColor = .systemGray6
        setupLayout()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Subviews

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGray6
        return tableView
    }()

    // MARK: - Private

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4.0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.0),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}
