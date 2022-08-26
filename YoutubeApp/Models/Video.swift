//
//  Video.swift
//  YoutubeApp
//
//  Created by Дмитро  on 25.08.2022.
//

import Foundation

class Video {
    var title: String
    var id: String
    var thumbnailURL: URL
    var playlist: Playlist?
    var viewsCount: Int = 0
    
    init(title: String, id: String, thumbnailURL: URL, playlist: Playlist? = nil) {
        self.title = title
        self.id = id
        self.thumbnailURL = thumbnailURL
        self.playlist = playlist
    }
}
