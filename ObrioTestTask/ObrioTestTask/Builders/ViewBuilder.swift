//
//  ViewBuilder.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//


import UIKit

final class ViewBuilder: BaseViewBuilder<UIView> {}

final class StackViewBuilder: BaseViewBuilder<UIStackView> {
    
    init(axis: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 0) {
        super.init(UIStackView())
        view.axis = axis
        view.spacing = spacing
    }

    @discardableResult func distribution(_ value: UIStackView.Distribution) -> Self {
        view.distribution = value
        return self
    }

    @discardableResult func alignment(_ value: UIStackView.Alignment) -> Self {
        view.alignment = value
        return self
    }

    @discardableResult func addArrangedSubview(_ view: UIView) -> Self {
        self.view.addArrangedSubview(view)
        return self
    }
}
