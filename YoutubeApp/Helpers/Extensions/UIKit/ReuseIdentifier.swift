//
//  ReuseIdentifier.swift
//  YoutubeApp
//
//  Created by Дмитро  on 28.08.2022.
//

import UIKit

protocol ReuseIdentifier { }

extension ReuseIdentifier {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}


extension UITableViewCell: ReuseIdentifier { }
extension UICollectionViewCell: ReuseIdentifier { }


