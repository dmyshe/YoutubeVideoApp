//
//  YouTubeBannerViewController.swift
//  YoutubeApp
//
//  Created by Дмитро  on 18.08.2022.
//

import UIKit
import SDWebImage

class YouTubeBannerViewController: UIViewController {
    @IBOutlet  weak var channelImageView: UIImageView!
    @IBOutlet  weak var channelNameLabel: UILabel!
    @IBOutlet  weak var channelSubscribersLabel: UILabel!
    
    var channel: Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

//MARK: - YouTubeBannerViewController
extension YouTubeBannerViewController {

    private func setupUI() {
        guard let channel = channel else { return }
        channelNameLabel.text = channel.title
        
        let subscribersCount = channel.subscribersCount.separateNumberIntoGroup()
        channelSubscribersLabel.text = "\(subscribersCount) подписчика"
        channelImageView.sd_setImage(with: channel.backGroundBannerURL)
    }
}
