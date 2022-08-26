//
//  VideoCollectionCell.swift
//  YoutubeApp
//
//  Created by Дмитро  on 20.08.2022.
//

import UIKit
import SDWebImage

class VideoCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "VideoCollectionCell"
    
    @IBOutlet private weak var channelPreviewImageView: UIImageView!
    @IBOutlet private weak var channelNameLabel: UILabel!
    @IBOutlet private weak var channelSubscriptionsCountLabel: UILabel!
    
    private let youTubeService = YouTubeServiceAdapter(apiKey: YoutubeAPI.apiKey)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        channelPreviewImageView.layer.cornerRadius = 6
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "VideoCollectionCell",
                     bundle: nil)
    }
    
    func configure(video: Video) {
        channelNameLabel.text = video.title

        Task.init {
            let viewsCount = await youTubeService.getVideoViewCount(byID: video.id)
            await MainActor.run {
                self.channelSubscriptionsCountLabel.text = "\(viewsCount) просмотров"
            }
        }
        
        channelPreviewImageView.sd_setImage(with: video.thumbnailURL)
    }
}
