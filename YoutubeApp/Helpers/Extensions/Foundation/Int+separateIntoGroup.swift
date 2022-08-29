//
//  Int+separateIntoGroup.swift
//  YoutubeApp
//
//  Created by Дмитро  on 28.08.2022.
//

import Foundation


extension Int {
    func separateNumberIntoGroup() -> String {
        let numberFormatter = NumberFormatter()

        numberFormatter.groupingSeparator = " "
        numberFormatter.numberStyle = .decimal

        return numberFormatter.string(from: self as NSNumber)!
    }
}
