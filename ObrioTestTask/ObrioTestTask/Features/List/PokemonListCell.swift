//
//  PokemonListCell.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import UIKit

final class PokemonListCell: UITableViewCell {

    var onFavoriteTap: (() -> Void)?
    var onDeleteTap: (() -> Void)?

    private let containerView = UIView()
    private let pokemonImageView = UIImageView()
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var imageTask: Task<Void, Never>?

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

private extension PokemonListCell {
    func setup() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true

        pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
        pokemonImageView.contentMode = .scaleAspectFit
        pokemonImageView.clipsToBounds = true

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.textColor = .label

        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        idLabel.textColor = .secondaryLabel

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        favoriteButton.tintColor = .systemYellow
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        contentView.addSubview(containerView)
        containerView.addSubview(pokemonImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(idLabel)
        containerView.addSubview(favoriteButton)
        containerView.addSubview(deleteButton)
        pokemonImageView.addSubview(activityIndicator)

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
