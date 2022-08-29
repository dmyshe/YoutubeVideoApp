//
//  UIColor+hex.swift
//  YoutubeApp
//
//  Created by Дмитро  on 23.08.2022.
//

import Foundation
import UIKit

public extension UIColor {
     convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
