//
//  YouTubeVideoPlayerViewController.swift
//  YoutubeApp
//
//  Created by Дмитро  on 18.08.2022.
//

import UIKit
import MediaPlayer
import youtube_ios_player_helper


protocol YouTubeVideoPlayerDataSource: AnyObject {
    func getVideoPlaylist() -> [Video]
    func getCurrentVideoPositionInPlaylist() -> Int
    
}
class YouTubeVideoPlayerViewController: UIViewController {
    @IBOutlet weak var handleAreaImageView: UIImageView!
    @IBOutlet weak var videoPlayerView: YTPlayerView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoViewsLabel: UILabel!
    @IBOutlet weak var playPreviousVideoButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playNextPlaylistVideo: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var videoDurationSlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var handleArea: UIStackView!
    @IBOutlet weak var durationSliderAndLabelsStackView: UIStackView!
    @IBOutlet weak var videoTitleAndViewCountStackView: UIStackView!
    @IBOutlet weak var controlsButtonStackView: UIStackView!
    @IBOutlet weak var volumeSliderAndIconsStackView: UIStackView!
    
    weak var dataSource: YouTubeVideoPlayerDataSource?
    
    var videoPlaylist: [Video]?
    
    private var volume: MPVolumeView!
    private var isVideoPlaying = false
    
    private var youtubeService = YouTubeServiceAdapter(apiKey: YoutubeAPI.apiKey)
    
    private var videoPositionInPlaylist : Int? {
        didSet {
            checkVideoPositionInPlaylist()
        }
    }
    
    private let withoutYTControls = [ "playsinline": 1,
                                      "autohide": 1,
                                      "showinfo": 0,
                                      "controls": 0,
                                      "frameborder": 0 ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientForBG()
        setSliderThumbLineImage()
        rotateHandleAreaImage()
        videoPlayerView.delegate = self
        hideUIElements(true)
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        if !isVideoPlaying {
            playButton.setImage(Resources.Images.pause, for: .normal)
            videoPlayerView.playVideo()
        } else {
            playButton.setImage(Resources.Images.play, for: .normal)
            videoPlayerView.stopVideo()
        }
        isVideoPlaying.toggle()
    }

    @IBAction func playPreviousPlaylistVideo(_ sender: UIButton) {
        videoPositionInPlaylist! -= 1
        loadPlaylistVideo()
    }
    
    @IBAction func playNextPlaylistVideo(_ sender: UIButton) {
        videoPositionInPlaylist! += 1
        loadPlaylistVideo()
    }
    
    
    @IBAction func volumeSliderChanged(_ sender: UISlider) {
//        guard let slider = volume.subviews.compactMap({ $0 as? UISlider }).first else {
//               return
//           }
//        slider.value = sender.value
    }
    
    
    @IBAction func videoDurationSliderChanged(_ sender: UISlider) {
        videoPlayerView.seek(toSeconds: sender.value, allowSeekAhead: true)
    }
    
    
    func configure(with video: Video) async {
        hideUIElements(true)
        Task {
            let viewsCount =  await youtubeService.getVideoViewCount(byID: video.id)
            await configureUI(video: video, viewsCount: viewsCount)
        }
    }

    func loadVideo(with id: String) {
        videoPlaylist = dataSource?.getVideoPlaylist()
        videoPositionInPlaylist = dataSource!.getCurrentVideoPositionInPlaylist()
        videoPlayerView.load(withVideoId: id, playerVars: withoutYTControls)
    }
    
    func loadPlaylistVideos(_ videos: [Video]) {
        videoPlaylist = videos
        videoPositionInPlaylist = 0
        loadPlaylistVideo()
    }
    
    private func loadPlaylistVideo() {
        guard let index = videoPositionInPlaylist else { return }
        let currentVideo = self.videoPlaylist![index]
        
        videoPlayerView.load(withVideoId: currentVideo.id, playerVars: withoutYTControls)
        
        Task {
            if let index = videoPositionInPlaylist,  let id = videoPlaylist?[index].id {
                let viewsCount = await  youtubeService.getVideoViewCount(byID: id)
            await configureUI(video: currentVideo, viewsCount: viewsCount)
            }
        }
    }
}

// MARK: - YTPlayerViewDelegate
extension YouTubeVideoPlayerViewController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .ended:
            playButton.setImage(Resources.Images.play, for: .normal)
        case .playing:
            playButton.setImage(Resources.Images.pause, for: .normal)
        case .paused:
            playButton.setImage(Resources.Images.play, for: .normal)
        default:
            break
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        currentTimeLabel.text = playTime.getTimeString()
        videoDurationSlider.value = playTime
        
        Task {
            let time = try await playerView.duration()
            await MainActor.run {
                let differenceTime =  Float(time) - playTime
                let remainingTime = differenceTime.getTimeString()
                set(remainingTimeText:  "-\(remainingTime)", videoDuration: playTime)
             }
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()

        Task {
            let duration = try await playerView.duration()
           await MainActor.run {
               set(remainingTimeText: Float(duration).getTimeString(), videoDuration: Float(duration))
               self.videoDurationSlider.maximumValue = Float(duration)
            }
        }
    }
}

extension YouTubeVideoPlayerViewController {
    
    private func checkVideoPositionInPlaylist() {
        if videoPositionInPlaylist! < 0 {
            self.videoPositionInPlaylist = 0
        }
        
        if videoPositionInPlaylist! > videoPlaylist!.count - 1 {
            self.videoPositionInPlaylist = videoPlaylist!.count - 1
        }

    }
    
    private func setGradientForBG() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            Resources.VideoPlayer.Colors.pink.cgColor,
            Resources.VideoPlayer.Colors.purple.cgColor,
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setSliderThumbLineImage() {
        let line = Resources.Images.line
        videoDurationSlider.setThumbImage(line, for: .normal)
    }
    
    
    private func rotateHandleAreaImage() {
        handleAreaImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi )
        handleAreaImageView.layer.borderColor = UIColor.red.cgColor
        handleAreaImageView.isUserInteractionEnabled = true
    }
    
    @MainActor
    private func configureUI(video: Video, viewsCount: Int) async {
        hideUIElements(false)
        videoTitleLabel.text = video.title
        videoViewsLabel.text = "\(viewsCount.separateNumberIntoGroup()) просмотров"
    }
    
    private func hideUIElements(_ bool: Bool) {
        durationSliderAndLabelsStackView.isHidden = bool
        videoTitleAndViewCountStackView.isHidden = bool
        controlsButtonStackView.isHidden = bool
        volumeSliderAndIconsStackView.isHidden = bool
    }
    
    
    private func set(remainingTimeText: String, videoDuration: Float) {
        self.remainingTimeLabel.text = remainingTimeText
    }
}

