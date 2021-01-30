import UIKit

class AlbumDetailsView: UIView {

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setupLayout()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Subviews

    let tableView = UITableView()

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
