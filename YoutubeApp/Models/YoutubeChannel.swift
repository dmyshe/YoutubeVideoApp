//
//  YoutubeChannel.swift
//  YoutubeApp
//
//  Created by Дмитро  on 19.08.2022.
//

import Foundation

class YoutubeChannelExample {
    var name: String
    var id: String
    var playlistID: String
    
    init(name: String, id: String, playlistID: String) {
        self.name = name
        self.id = id
        self.playlistID = playlistID
    }
    
    
    static var exampleData = [
        YoutubeChannelExample(name: "Dragons", id: "UCT9zcQNlyht7fRlcjmflRSA", playlistID: "lBv5o1PR9aG5hsk5T9ekXW5THQNd4"),
        YoutubeChannelExample(name: "MarcusBrownlee", id: "UCBJycsmduvYEL83R_U4JriQ", playlistID: "lBv5o1PR9aG5hsk5T9ekXW5THQNd4"),
        YoutubeChannelExample(name: "Paul Hudson", id: "UCmJi5RdDLgzvkl3Ly0DRMlQ", playlistID: "PLuoeXyslFTuar0FSCJJ-kJ5p9_RDVNMhV"),
        YoutubeChannelExample(name: "Stanford", id: "UC-EnprmCZ3OXyAoG7vjVNCA" , playlistID: "PLpGHT1n4-mAvOTorN-uG1EzFz_sA5Qw3m"),
        YoutubeChannelExample(name: "Chess.Com", id: "UC5kS0l76kC0xOzMPtOmSFGw", playlistID: "PL-qLOQ-OEls41aLi2OH039ZJxarjevA9r")
    ]
}



