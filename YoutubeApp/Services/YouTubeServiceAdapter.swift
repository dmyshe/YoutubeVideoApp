//
//  YoutubeClient.swift
//  YoutubeApp
//
//  Created by Дмитро  on 23.08.2022.
//

import Foundation
import GoogleAPIClientForREST

class YouTubeServiceAdapter {
    private let service = GTLRYouTubeService()
        
    init(apiKey: String) {
        service.apiKey = apiKey
    }
    
    public func getChannelInfo(channelID: String ,queryPart: String = "snippet,brandingSettings,statistics") async -> Channel  {
        await withCheckedContinuation { continuation in
            self.getChannelInfo(channelID: channelID) { channel in
                continuation.resume(returning: channel)
            }
        }
    }
    
    public func getFullPlaylistVideos(playlistID id: String, queryPart: String = "snippet") async -> [Video] {
        let videos = await getPlaylistVideos(playlistID: id)
        let playlist = await getPlaylistInfo(playlistID: id)
        
        videos.forEach { $0.playlist = playlist }
        
        return videos
    }
    
    public func getVideoViewCount(byID id: String, queryPart: String = "statistics") async -> Int {
        await withCheckedContinuation { continuation in
            self.getVideoViewCount(byID: id) { viewCount in
                continuation.resume(returning: viewCount)
            }
        }
    }
    
    
    public func getPlaylistVideos( playlistID id: String, queryPart: String = "snippet") async -> [Video] {
        await withCheckedContinuation { continuation in
            self.getPlaylistVideos(playlistID: id) { videos in
                continuation.resume(returning: videos)
            }
        }
    }
    
    public func getPlaylistInfo(playlistID id: String, queryPart: String = "snippet") async -> Playlist {
        await withCheckedContinuation{ continuation in
            self.getVideoPlaylistTitle(playlistID: id) { playlist in
                continuation.resume(returning: playlist)
            }
        }
    }
}


extension YouTubeServiceAdapter {
    
    private func getChannelInfo(channelID: String ,queryPart: String = "snippet,brandingSettings,statistics",completionHandler: @escaping (Channel) -> Void ) {
        let channelQuery = GTLRYouTubeQuery_ChannelsList.query(withPart: queryPart)
        channelQuery.identifier = channelID
        
        service.executeQuery(channelQuery) { _, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let channelInfo = response as? GTLRYouTube_ChannelListResponse,
                  let channelInfoItem = channelInfo.items?.first,
                  let channelTitle = channelInfoItem.snippet?.title,
                  let channelID = channelInfo.items?.first?.identifier,
                  let channelSubscribers = channelInfoItem.statistics?.subscriberCount as? Int,
                  let channelBGBannerURL = channelInfoItem.brandingSettings?.image?.bannerExternalUrl else { return }
            
            completionHandler(Channel(title: channelTitle,
                                      id: channelID,
                                      subscribersCount: channelSubscribers,
                                      backGroundBannerURL: URL(string: channelBGBannerURL)!))
        }
    }

    private func getPlaylistVideos( playlistID id: String, queryPart: String = "snippet", completionHandler: @escaping ([Video]) -> Void) {
        let playlistItemsListQuery = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: queryPart)
        playlistItemsListQuery.playlistId = id
        playlistItemsListQuery.maxResults = 10

        service.executeQuery(playlistItemsListQuery) { _, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let response = response as? GTLRYouTube_PlaylistItemListResponse  else { return }
            
            guard let items = response.items else {
                print("response items is empty")
                return
            }
            
            var playlistVideos = [Video]()
           
            
            for item in items {
                guard let videoInfo = item.snippet,
                      let videoTitle = videoInfo.title,
                      let videoID = item.snippet?.resourceId?.videoId,
                      let thumbnailURL = videoInfo.thumbnails?.medium?.url
                else { return }
                
                let video = Video(title: videoTitle ,
                                  id: videoID,
                                  thumbnailURL: URL(string: thumbnailURL)!)
                
                playlistVideos.append(video)
            }
            completionHandler(playlistVideos)
        }
    }
    
    
    private func getVideoViewCount(byID id: String, queryPart: String = "statistics", completionHandler: @escaping (Int) -> Void) {
        let videoQuery = GTLRYouTubeQuery_VideosList.query(withPart: queryPart)
        videoQuery.identifier = id

        service.executeQuery(videoQuery) { _, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let response = response as? GTLRYouTube_VideoListResponse,
                  let viewCount = response.items?.first?.statistics?.viewCount as? Int
            else { return }
            completionHandler(viewCount)
        }
    }

    private func getVideoPlaylistTitle(playlistID id: String, queryPart: String = "snippet",completionHandler: @escaping (Playlist) -> Void) {
        
        let playlistListQuery = GTLRYouTubeQuery_PlaylistsList.query(withPart: queryPart)
        playlistListQuery.identifier = id
        
        service.executeQuery(playlistListQuery) { _, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let response = response as? GTLRYouTube_PlaylistListResponse else { return }
            
            guard let items = response.items,
                  let playlistVideo = items.first,
                  let playlistName = playlistVideo.snippet?.title,
                  let playListID = playlistVideo.identifier else {
                print("response items is empty")
                return
            }
           completionHandler(Playlist(name: playlistName, id: playListID))
        }
    }
}
