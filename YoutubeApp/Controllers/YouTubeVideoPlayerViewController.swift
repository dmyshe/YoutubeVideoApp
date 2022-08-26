//
//  YouTubeVideoPlayerViewController.swift
//  YoutubeApp
//
//  Created by Дмитро  on 18.08.2022.
//

import UIKit
import MediaPlayer
import youtube_ios_player_helper
import SDWebImage

protocol YouTubeVideoPlayerViewDelegate: AnyObject {
    func previousPlaylistVideoButtonPressed(_ vc: YouTubeVideoPlayerViewController)
    func nextPlaylistVideoButtonPressed(_ vc: YouTubeVideoPlayerViewController)
}

protocol YouTubeVideoPlayerDataSource: AnyObject {
    func getVideo(position: Int) -> Video
    func getCurrentVideoPositionInPlaylist() -> Int
    func numbersOfVideosInPlaylist(position: Int) -> Int
    
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
    
    weak var delegate: YouTubeVideoPlayerViewDelegate?
    weak var dataSource: YouTubeVideoPlayerDataSource?
    
    private var volume: MPVolumeView!
    private var isVideoPlaying = false
    
    private var youtubeService = YouTubeServiceAdapter(apiKey: YoutubeAPI.apiKey)
    
    private var videoPositionInPlaylist = 0
    private var videoPlaylistCount: Int {
        dataSource?.numbersOfVideosInPlaylist(position: videoPositionInPlaylist) ?? 0
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
        Task {
            if videoPositionInPlaylist <= -1 && videoPositionInPlaylist < videoPlaylistCount  { videoPositionInPlaylist = 0 }
            let video = dataSource!.getVideo(position: videoPositionInPlaylist)
            videoPlayerView.load(withVideoId: video.id, playerVars: withoutYTControls)
            let viewsCount =  await youtubeService.getVideoViewCount(byID: video.id)
            await configureUI(video: video, viewsCount: viewsCount)
            videoPositionInPlaylist -= 1
        }
    }
    
    @IBAction func playNextPlaylistVideo(_ sender: UIButton) {
        Task {
            if videoPositionInPlaylist <= -1 && videoPositionInPlaylist < videoPlaylistCount  { videoPositionInPlaylist = 0  }
            let video = dataSource!.getVideo(position: videoPositionInPlaylist)
            videoPlayerView.load(withVideoId: video.id, playerVars: withoutYTControls)
            
            let viewsCount =  await youtubeService.getVideoViewCount(byID: video.id)
            await configureUI(video: video, viewsCount: viewsCount)
            videoPositionInPlaylist += 1
        }
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

    func loadVideoWith(id: String) {
        videoPlayerView.load(withVideoId: id, playerVars: withoutYTControls)
    }
    
    func loadVideoPlaylist(id: String) {
        videoPlayerView.load(withPlaylistId: id, playerVars: withoutYTControls)
    }
    
    func initiateVCFromStoryboard() -> YouTubeVideoPlayerViewController {
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let vc = storyboard.instantiateViewController(withIdentifier: "YouTubeVideoPlayerViewController") as! YouTubeVideoPlayerViewController
       return vc
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
        currentTimeLabel.text = getTimeString(from: playTime)
        
        playerView.duration { [weak self] time, error in
            DispatchQueue.main.async {
                self?.remainingTimeLabel.text = self?.getTimeString(from: Float(time))
                let differenceTime =  Float(time) - playTime
                let remainingTime = self!.getTimeString(from: Float(differenceTime))
                self?.remainingTimeLabel.text = "-\(remainingTime)"
                self?.videoDurationSlider.value = playTime
            }
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()

        playerView.duration { [weak self] time, error in
            DispatchQueue.main.async {
                self?.remainingTimeLabel.text = self?.getTimeString(from: Float(time))
                self?.videoDurationSlider.maximumValue = Float(time)
            }
        }
    }
}

// MARK: - YouTubeVideoPlayerViewController
extension YouTubeVideoPlayerViewController {
    private func getTimeString(from time: Float)  -> String {
        let totalSeconds = time
        let hours = Int (totalSeconds/3600)
        let minutes = Int (totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
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
//        handleAreaImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
//        handleAreaImageView.isUserInteractionEnabled = true
    }
    
    @MainActor
    private func configureUI(video: Video, viewsCount: Int) async {
        hideUIElements(false)
        videoTitleLabel.text = video.title
        videoViewsLabel.text = "\(viewsCount) просмотров"
    }
    
    private func hideUIElements(_ bool: Bool) {
        videoDurationSlider.isHidden = bool
        remainingTimeLabel.isHidden = bool
        currentTimeLabel.isHidden = bool
        
        playPreviousVideoButton.isHidden = bool
        playButton.isHidden = bool
        playNextPlaylistVideo.isHidden = bool
        
        videoTitleLabel.isHidden = bool
        videoViewsLabel.isHidden = bool
        volumeSlider.isHidden = bool
        
    }
}

