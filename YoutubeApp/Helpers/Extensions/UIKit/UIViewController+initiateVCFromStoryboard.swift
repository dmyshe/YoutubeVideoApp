//
//  Storyboard.swift
//  YoutubeApp
//
//  Created by Дмитро  on 28.08.2022.
//

import Foundation
import UIKit


protocol StoryboardInitialization {
    func initiateVCFromStoryboard() -> Self
}

extension StoryboardInitialization {
    func initiateVCFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: Self.self)) as! Self
        return vc
    }
}

extension UIViewController: StoryboardInitialization  { }


