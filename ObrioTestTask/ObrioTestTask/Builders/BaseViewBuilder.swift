//
//  BaseViewBuilder.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//

import UIKit

class BaseViewBuilder<T: UIView>: Buildable {
    let view: T
    
    init(_ view: T = T()) {
        self.view = view
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @discardableResult func backgroundColor(_ c: UIColor?) -> Self {
        view.backgroundColor = c; return self
    }
    
    @discardableResult func hidden(_ h: Bool) -> Self {
        view.isHidden = h; return self
    }
    
    @discardableResult func clipsToBounds(_ clips: Bool = true) -> Self {
        view.clipsToBounds = clips; return self
    }
    
    @discardableResult func cornerRadius(_ r: CGFloat) -> Self {
        view.layer.cornerRadius = r; view.layer.masksToBounds = true; return self
    }
    
    @discardableResult func contentMode(_ m: UIView.ContentMode) -> Self {
        view.contentMode = m; return self
    }
    
    @discardableResult func add(to superview: UIView) -> Self {
        superview.addSubview(view); return self
    }
    func build() -> T { view }
}
