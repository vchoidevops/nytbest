//
//  UIFont.swift
//  NYBest
//
//  Created by Woongshik Choi on 2/21/22.
//

import UIKit

extension UIFont {
    static var newYorkFont: UIFont {
        let descriptor = UIFont.systemFont(ofSize: 12, weight: .semibold).fontDescriptor
        if let self = descriptor.withDesign(.serif) {
            return UIFont(descriptor: self, size: 0)
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
