//
//  VideoCollectionCell.swift
//  YoutubeApp
//
//  Created by Дмитро  on 20.08.2022.
//

import UIKit
import SDWebImage

class VideoCollectionCell: UICollectionViewCell {    
    @IBOutlet private weak var channelPreviewImageView: UIImageView!
    @IBOutlet private weak var channelNameLabel: UILabel!
    @IBOutlet private weak var channelSubscriptionsCountLabel: UILabel!
    
    private let youTubeService = YouTubeServiceAdapter(apiKey: YoutubeAPI.apiKey)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        channelPreviewImageView.layer.cornerRadius = Resources.VideoCell.cornerRadius
    }
    
    func configure(video: Video) {
        channelNameLabel.text = video.title

        Task.init {
            let viewsCount = await youTubeService.getVideoViewCount(byID: video.id)
            await MainActor.run {
                self.channelSubscriptionsCountLabel.text = "\(viewsCount.separateNumberIntoGroup()) просмотров"
            }
        }
        
        channelPreviewImageView.sd_setImage(with: video.thumbnailURL)
    }
}
