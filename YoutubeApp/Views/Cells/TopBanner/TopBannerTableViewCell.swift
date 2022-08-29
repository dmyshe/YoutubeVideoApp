//
//  TopBannerTableViewCell.swift
//  YoutubeApp
//
//  Created by Дмитро  on 21.08.2022.
//

import UIKit
import SDWebImage

class TopBannerTableViewCell: UITableViewCell {    
    @IBOutlet  weak var bannerView: UIView!
    
    let pageViewController = YouTubeBannerPageViewController()

    override  func awakeFromNib() {
        super.awakeFromNib()
        bannerView.layer.cornerRadius = Resources.PageBannerVC.cornerRadius
        pageViewController.view.frame = self.bannerView.bounds

        self.bannerView.addSubview(pageViewController.view)
    }
}
