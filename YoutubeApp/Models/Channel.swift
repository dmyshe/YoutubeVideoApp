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
    var backGroundBannerURL: URL?
    var videoPlaylists: [Playlist]?
}


// Its only get id, because I can't load a random YouTube YouTube channel. see 
extension Channel {
    static var exampleData = [
        Channel(title: "ImagineDragons",
                id: "UCT9zcQNlyht7fRlcjmflRSA", subscribersCount: 0),
        
        Channel(title: "Marques Brownlee",
                id: "UCBJycsmduvYEL83R_U4JriQ",
                subscribersCount: 0),
        
        Channel(title: "Paul Hudson",
                id: "UCmJi5RdDLgzvkl3Ly0DRMlQ",
                subscribersCount: 0),
        
        Channel(title: "Stanford",
                id: "UC-EnprmCZ3OXyAoG7vjVNCA",
                subscribersCount: 0),
    ]
}
