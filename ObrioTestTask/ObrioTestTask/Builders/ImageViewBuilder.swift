//
//  ImageViewBuilder.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//

import UIKit

final class ImageViewBuilder: BaseViewBuilder<UIImageView> {
    
    @discardableResult func image(_ i: UIImage?) -> Self {
        view.image = i; return self
    }
    
    @discardableResult func tintColor(_ c: UIColor) -> Self {
        view.tintColor = c; return self
    }
}
