//
//  UIVIew+Extension.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
