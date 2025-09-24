//
//  PokemonDetailViewController.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import UIKit
import Combine

final class PokemonDetailViewController: UIViewController {
    private let store: Store<PokemonDetailReducer>
    private let fallbackImageURL: URL?
    @Inject private var imageLoader: ImageLoading

    private var cancellables = Set<AnyCancellable>()
    private var currentState: PokemonDetailState

    private let scrollView = UIScrollView()
    private let contentView: UIView = ViewBuilder().build()
    private let imageView: UIImageView = ImageViewBuilder()
        .contentMode(.scaleAspectFit)
        .clipsToBounds()
        .cornerRadius(16)
        .backgroundColor(.secondarySystemBackground)
        .build()
    private let nameLabel: UILabel = LabelBuilder()
        .font(UIFont.preferredFont(forTextStyle: .largeTitle))
        .textColor(.label)
        .alignment(.center)
        .build()
    private let heightLabel: UILabel = LabelBuilder()
        .font(UIFont.preferredFont(forTextStyle: .title3))
        .textColor(.secondaryLabel)
        .build()
    private let weightLabel: UILabel = LabelBuilder()
        .font(UIFont.preferredFont(forTextStyle: .title3))
        .textColor(.secondaryLabel)
        .build()
    private let favoriteButton: UIButton = ButtonBuilder(.system)
        .build()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let detailActivityIndicator = UIActivityIndicatorView(style: .medium)

    private var imageTask: Task<Void, Never>?
    private var displayedImageURL: URL?

    init(store: Store<PokemonDetailReducer>, imageURL: URL?) {
        self.store = store
        self.fallbackImageURL = imageURL
        self.currentState = store.state
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindStore()
        store.send(.observeFavorites)
        store.send(.onAppear)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageTask?.cancel()
    }
}

private extension PokemonDetailViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = currentState.name

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setTitle("Add to Favorites", for: .normal)
        favoriteButton.setTitle("Remove Favorite", for: .selected)
        favoriteButton.configuration = .filled()
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        favoriteButton.configurationUpdateHandler = { button in
            if button.isSelected {
                button.configuration?.baseBackgroundColor = .systemRed
            } else {
                button.configuration?.baseBackgroundColor = .systemBlue
            }
        }

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        detailActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        detailActivityIndicator.hidesWhenStopped = true

        view.addSubviews(scrollView, activityIndicator)
        scrollView.addSubviews(contentView)
        contentView.addSubviews(imageView, detailActivityIndicator, nameLabel, heightLabel, weightLabel, favoriteButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 220),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            detailActivityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            detailActivityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            heightLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            heightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            heightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            weightLabel.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 12),
            weightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            favoriteButton.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 32),
            favoriteButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            favoriteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            favoriteButton.widthAnchor.constraint(equalToConstant: 220),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func bindStore() {
        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    func render(_ state: PokemonDetailState) {
        currentState = state

        state.isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        favoriteButton.isSelected = state.isFavorite
        favoriteButton.setNeedsUpdateConfiguration()

        title = state.detail?.name ?? state.name

        nameLabel.text = state.detail?.name ?? currentState.name
        heightLabel.text = state.detail.map { "Height: \($0.formattedHeight)" }
        weightLabel.text = state.detail.map { "Weight: \($0.formattedWeight)" }

        if let detail = state.detail {
            loadImage(from: detail.imageURL ?? fallbackImageURL)
        } else if !state.isLoading {
            loadImage(from: fallbackImageURL)
        }

        if let error = state.errorMessage, presentedViewController == nil {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            store.send(.dismissError)
        }
    }

    func loadImage(from url: URL?) {
        guard let url else { return }
        guard url != displayedImageURL else { return }
        displayedImageURL = url
        detailActivityIndicator.startAnimating()
        imageTask?.cancel()
        imageTask = Task { [weak self] in
            do {
                let image = try await self?.imageLoader.loadImage(from: url)
                self?.applyImage(image)
            } catch {
                self?.handleImageFailure()
            }
        }
    }

    @objc func favoriteTapped() {
        store.send(.toggleFavorite)
    }

    @MainActor
    func applyImage(_ image: UIImage?) {
        detailActivityIndicator.stopAnimating()
        imageView.image = image ?? UIImage(systemName: "questionmark")
    }

    @MainActor
    func handleImageFailure() {
        detailActivityIndicator.stopAnimating()
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        displayedImageURL = nil
    }
}
