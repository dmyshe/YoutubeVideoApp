//
//  Channel.swift
//  YoutubeApp
//
//  Created by Дмитро  on 24.08.2022.
//

import Foundation

struct Channel {
    var title: String
    var id: String
    var subscribersCount: Int
    var backGroundBannerURL: URL
    var videoPlaylists: [Playlist]?
}

