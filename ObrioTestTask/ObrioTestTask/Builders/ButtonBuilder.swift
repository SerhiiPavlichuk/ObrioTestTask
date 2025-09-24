//
//  ButtonBuilder.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//

import UIKit

final class ButtonBuilder: BaseViewBuilder<UIButton> {
    
    init(_ type: UIButton.ButtonType = .system) {
        super.init(UIButton(type: type))
    }
    
    @discardableResult func title(_ t: String?, for state: UIControl.State = .normal) -> Self {
        view.setTitle(t, for: state); return self
    }
    
    @discardableResult func titleColor(_ c: UIColor, for state: UIControl.State = .normal) -> Self {
        view.setTitleColor(c, for: state); return self
    }
    
    @discardableResult func image(_ i: UIImage?, for state: UIControl.State = .normal) -> Self {
        view.setImage(i, for: state); return self
    }

}
