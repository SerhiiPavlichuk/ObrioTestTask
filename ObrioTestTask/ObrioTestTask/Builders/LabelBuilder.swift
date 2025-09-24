//
//  LabelBuilder.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//

import UIKit

final class LabelBuilder: BaseViewBuilder<UILabel> {
    @discardableResult func text(_ v: String?) -> Self {
        view.text = v; return self
    }
    
    @discardableResult func textColor(_ c: UIColor) -> Self {
        view.textColor = c; return self
    }
    
    @discardableResult func font(_ f: UIFont) -> Self {
        view.font = f; return self
    }
    
    @discardableResult func alignment(_ a: NSTextAlignment) -> Self {
        view.textAlignment = a; return self
    }
    
    @discardableResult func numberOfLines(_ n: Int) -> Self {
        view.numberOfLines = n; return self
    }
}
