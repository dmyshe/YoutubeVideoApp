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
    public func initiateVCFromStoryboard() -> YouTubeBannerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "YouTubeBannerViewController") as! YouTubeBannerViewController
        return vc
    }
    
    private func setupUI() {
        channelNameLabel.text = channel?.title
        channelSubscribersLabel.text = "\(channel!.subscribersCount) подписчиков"
        channelImageView.sd_setImage(with: channel?.backGroundBannerURL)
    }
}
