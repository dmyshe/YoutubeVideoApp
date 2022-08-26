//
//  Resources.swift
//  YoutubeApp
//
//  Created by Дмитро  on 19.08.2022.
//

import UIKit


struct Resources {
    enum Images {
        static let play = UIImage(named: "Play")!
        static let pause = UIImage(named: "Pause")!
        static let line = UIImage(named: "line")!
        static let closeOpen = UIImage(named: "Close_Open")!
    }
    
    enum VideoPlayer {
        static let cardHandleAreaHeight: CGFloat = 45
        static let padding: CGFloat = 5
        static let cornerRadius: CGFloat = 15
        static let cornerRadiusAfterAnimation: CGFloat = 20
        static let backgroundDarker: CGFloat = 0.6
       
        static func cardHeight(view: UIView) -> CGFloat {
            view.bounds.height / 1.2
        }
        
        enum Colors {
            static let pink =  UIColor(named: "videoplayer_bgGradientTop")!
            static let purple =  UIColor(named: "videoplayer_bgGradientBottom")!
        }
    }
    
    enum PageBannerVC {
        static let cornerRadius: CGFloat = 4
    }
}
