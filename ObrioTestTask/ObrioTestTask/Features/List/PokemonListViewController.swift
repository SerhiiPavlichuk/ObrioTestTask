//
//  PokemonListViewController.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import UIKit
import Combine

final class PokemonListViewController: UIViewController {
    private let store: Store<PokemonListReducer>
    @Inject private var imageLoader: ImageLoading

    private var cancellables = Set<AnyCancellable>()
    private var currentState = PokemonListState()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PokemonListCell.self, forCellReuseIdentifier: PokemonListCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        return tableView
    }()

    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        return control
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = LabelBuilder()
            .font(UIFont.preferredFont(forTextStyle: .headline))
            .textColor(.secondaryLabel)
            .alignment(.center)
            .text("No Pokémon yet")
            .build()
        label.isHidden = true
        return label
    }()

    private let paginationIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let favoritesCounterLabel: UILabel = {
        let label = LabelBuilder()
            .font(UIFont.preferredFont(forTextStyle: .caption1))
            .textColor(.white)
            .alignment(.center)
            .build()
        label.backgroundColor = .systemRed
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        return label
    }()

    init(store: Store<PokemonListReducer>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindStore()
        store.send(.onAppear)
        store.send(.observeFavorites)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        paginationIndicator.frame.size.width = tableView.bounds.width
    }
}

private extension PokemonListViewController {
    func setupUI() {
        title = "Pokémon"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = makeFavoritesBarButton()

        view.addSubviews(tableView, loadingIndicator, emptyStateLabel)
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)

        paginationIndicator.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        tableView.tableFooterView = paginationIndicator

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func makeFavoritesBarButton() -> UIBarButtonItem {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = ImageViewBuilder()
            .image(UIImage(systemName: "star.fill"))
            .tintColor(.systemYellow)
            .build()
        favoritesCounterLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubviews(imageView, favoritesCounterLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            favoritesCounterLabel.topAnchor.constraint(equalTo: container.topAnchor),
            favoritesCounterLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            favoritesCounterLabel.heightAnchor.constraint(equalToConstant: 20)
        ])

        favoritesCounterLabel.isHidden = true
        return UIBarButtonItem(customView: container)
    }

    func bindStore() {
        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    func render(_ state: PokemonListState) {
        currentState = state

        state.isInitialLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()

        if refreshControl.isRefreshing && !state.isInitialLoading && !state.isPaginating {
            refreshControl.endRefreshing()
        }

        emptyStateLabel.isHidden = !(!state.isInitialLoading && state.items.isEmpty && state.errorMessage == nil)

        updateFavoritesCounter(count: state.favoritesCount)

        state.isPaginating ? paginationIndicator.startAnimating() : paginationIndicator.stopAnimating()

        tableView.reloadData()

        if let message = state.errorMessage {
            presentError(message)
            store.send(.dismissError)
        }
    }

    func updateFavoritesCounter(count: Int) {
        favoritesCounterLabel.text = " \(count) "
        favoritesCounterLabel.isHidden = count == 0
    }

    func presentError(_ message: String) {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc func refreshPulled() {
        store.send(.refresh)
    }
}

extension PokemonListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentState.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PokemonListCell.reuseIdentifier, for: indexPath) as? PokemonListCell else {
            return UITableViewCell()
        }

        let item = currentState.items[indexPath.row]
        let isFavorite = currentState.favorites.contains(item.id)
        cell.configure(with: item, isFavorite: isFavorite, imageLoader: imageLoader)
        cell.onFavoriteTap = { [weak self] in
            self?.store.send(.toggleFavorite(id: item.id))
        }
        cell.onDeleteTap = { [weak self] in
            self?.store.send(.delete(id: item.id))
        }
        return cell
    }
}

extension PokemonListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = currentState.items[indexPath.row]
        let detailState = PokemonDetailState(id: item.id, name: item.name)
        let detailReducer = PokemonDetailReducer()
        let detailStore = Store(initialState: detailState, reducer: detailReducer)
        let detailController = PokemonDetailViewController(store: detailStore, imageURL: item.spriteURL)
        navigationController?.pushViewController(detailController, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        guard contentHeight > 0, offsetY > contentHeight - frameHeight * 1.5 else { return }
        if currentState.canLoadMore && !currentState.isPaginating && !currentState.isInitialLoading {
            store.send(.loadMore)
        }
    }
}
