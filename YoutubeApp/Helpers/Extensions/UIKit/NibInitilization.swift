//
//  NibInitilization.swift
//  YoutubeApp
//
//  Created by Дмитро  on 28.08.2022.
//

import UIKit

protocol UINibInitialization {}

extension UINibInitialization {
    static func nib() -> UINib {
        return UINib(nibName: String(describing: Self.self),
                     bundle: nil)
    }
}

extension UITableViewCell: UINibInitialization { }
extension UICollectionViewCell: UINibInitialization { }
