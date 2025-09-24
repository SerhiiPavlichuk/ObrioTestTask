//
//  PokemonListCell.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import UIKit

final class PokemonListCell: UITableViewCell {

    //MARK: - Properties
    
    static let reuseIdentifier = "PokemonListCell"

    var onFavoriteTap: (() -> Void)?
    var onDeleteTap: (() -> Void)?

    //MARK: - Views
    
    private let containerView: UIView = ViewBuilder()
        .backgroundColor(.secondarySystemBackground)
        .cornerRadius(12)
        .clipsToBounds()
        .build()

    private let pokemonImageView: UIImageView = ImageViewBuilder()
        .contentMode(.scaleAspectFit)
        .clipsToBounds()
        .build()

    private let nameLabel: UILabel = LabelBuilder()
        .font(UIFont.preferredFont(forTextStyle: .headline))
        .textColor(.label)
        .build()

    private let idLabel: UILabel = LabelBuilder()
        .font(UIFont.preferredFont(forTextStyle: .subheadline))
        .textColor(.secondaryLabel)
        .build()

    private let favoriteButton: UIButton = ButtonBuilder(.system)
        .build()

    private let deleteButton: UIButton = ButtonBuilder(.system)
        .build()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var imageTask: Task<Void, Never>?

    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        pokemonImageView.image = nil
        activityIndicator.stopAnimating()
        imageTask?.cancel()
        imageTask = nil
    }

    //MARK: - Methods
    
    func configure(with item: PokemonListItem, isFavorite: Bool, imageLoader: ImageLoading) {
        nameLabel.text = item.name
        idLabel.text = String(format: "#%03d", item.id)
        favoriteButton.isSelected = isFavorite

        guard let url = item.spriteURL else {
            activityIndicator.stopAnimating()
            pokemonImageView.image = UIImage(systemName: "questionmark")
            return
        }

        activityIndicator.startAnimating()
        imageTask?.cancel()
        imageTask = Task { [weak self] in
            do {
                let image = try await imageLoader.loadImage(from: url)
                self?.applyImage(image)
            } catch {
                self?.applyImage(UIImage(systemName: "exclamationmark.triangle"))
            }
        }
    }
}

    //MARK: - Setup

private extension PokemonListCell {
    func setup() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground

        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        favoriteButton.tintColor = .systemYellow
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)

        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        contentView.addSubviews(containerView)
        containerView.addSubviews(pokemonImageView, nameLabel, idLabel, favoriteButton, deleteButton)
        pokemonImageView.addSubviews(activityIndicator)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            pokemonImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            pokemonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 68),
            pokemonImageView.widthAnchor.constraint(equalTo: pokemonImageView.heightAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: pokemonImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: pokemonImageView.centerYAnchor),

            favoriteButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -12),
            favoriteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),

            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 32),
            deleteButton.heightAnchor.constraint(equalToConstant: 32),

            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -8),

            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -8),
            idLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    @objc func favoriteTapped() {
        onFavoriteTap?()
    }

    @objc func deleteTapped() {
        onDeleteTap?()
    }

    @MainActor
    func applyImage(_ image: UIImage?) {
        activityIndicator.stopAnimating()
        pokemonImageView.image = image
    }
}
