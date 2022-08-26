//
//  YouTubeVideoListViewController.swift
//  YoutubeApp
//
//  Created by Дмитро  on 18.08.2022.
//

import UIKit

class YouTubeVideoListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var videoPlayerVC: YouTubeVideoPlayerViewController!
    var blackView: UIView!
    var blackViewForNavigation: UIView!
    
    lazy var cardHeight: CGFloat = view.bounds.height / 1.2
    
    var bottomSheetVisible = false
    
    enum YouTubeCellType: Int {
        case banner, playlistSmall, playlistLarge
    }
    
    enum BottomSheetState {
        case expanded, collapsed
    }
    
    private var nextState: BottomSheetState {
        return bottomSheetVisible ?  .collapsed : .expanded
    }
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    
    private var channel = [Channel]()
    private var videos = [[Video]]()
    
    var (videoPositionInPlaylist, playlistNumber) = (0,0)
    
    
    private let youTubeService = YouTubeServiceAdapter(apiKey: YoutubeAPI.apiKey)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addGestureRecognizer()
        fetchData()
    }
        
   private func fetchData() {
        Task.init {
            let playlist1 = await youTubeService.getFullPlaylistVideos(playlistID: Dragons.testPlaylist1)
            self.videos.append(playlist1)
            
            let playlist2 = await youTubeService.getFullPlaylistVideos(playlistID: MarcusBrownlee.testPlaylist1)
            self.videos.append(playlist2)
            
            await self.showTableView()
        }
    }
}

//MARK: - UITableViewDelegate
extension YouTubeVideoListViewController: UITableViewDelegate {

}

//MARK: - UITableViewDataSource
extension YouTubeVideoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentCell = YouTubeCellType(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch currentCell {
        case .banner:
            return createYouTubeBannerCell(tableView, indexPath)
        case .playlistSmall:
            return createPlaylistCell(tableView, indexPath)
        case .playlistLarge:
            return createPlaylistCell(tableView, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard !videos.isEmpty, section > 0 else { return nil }
        let currentVideoTitle = videos[section - 1].first?.title
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionTitleTableViewCell.reuseIdentifier) as! SectionTitleTableViewCell
        
        guard let currentCell = YouTubeCellType(rawValue: section) else { return nil }
        switch currentCell {
        case .banner:
            return nil
        case .playlistSmall:
            cell.title.text = currentVideoTitle
        case .playlistLarge:
            cell.title.text = currentVideoTitle
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCell = YouTubeCellType(rawValue: indexPath.section)!
        switch currentCell {
        case .banner:
            return 250
        case .playlistSmall:
            return 110
        case .playlistLarge:
            return 180
        }
    }
}

//MARK: - Configure Cell
extension YouTubeVideoListViewController {
    
    func createYouTubeBannerCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopBannerTableViewCell.reuseIdentifier, for: indexPath) as! TopBannerTableViewCell
        cell.pageViewController.bannerInfoDelegate = self
        return cell
    }
    
    func createPlaylistCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        
        guard !videos.isEmpty else { return  UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.reuseIdentifier , for: indexPath) as! PlaylistTableViewCell
        
        let currentVideoPlaylist = videos[indexPath.section - 1]
        cell.videos = currentVideoPlaylist
        
        let currentCell = YouTubeCellType(rawValue: indexPath.section)!
        switch currentCell {
        case .playlistSmall:
            cell.tag = currentCell.rawValue
            cell.configure(cellSize: .small)
        case .playlistLarge:
            cell.tag = currentCell.rawValue
            cell.configure(cellSize: .large)
        default:
            break
        }
        cell.delegate = self
        
        return cell
    }
}

extension YouTubeVideoListViewController {
    func addGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan))
        videoPlayerVC.handleAreaImageView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.videoPlayerVC.handleAreaImageView)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = bottomSheetVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
            
        default:
            break
        }
    }
    
    private func startInteractiveTransition(state: BottomSheetState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animation in runningAnimations {
            animation.pauseAnimation()
            animationProgressWhenInterrupted = animation.fractionComplete
        }
    }
    
    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animation in runningAnimations {
            animation.fractionComplete =  fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    private func animateTransitionIfNeeded(state: BottomSheetState, duration: TimeInterval) {
        guard runningAnimations.isEmpty else { return }
        
        let collapseBottomSheet = {
            self.videoPlayerVC.view.frame.origin.y = self.view.frame.height - Resources.VideoPlayer.cardHandleAreaHeight
        }
        
        let expandBottomSheet = {
            self.videoPlayerVC.view.frame.origin.y = self.view.frame.height - self.cardHeight
        }
        
        let frameAnimator = createPropertyAnimator(state: state,
                                                   onExpanded: expandBottomSheet(),
                                                   onCollapsed: collapseBottomSheet(),
                                                   duration: duration)
        
        startPropertyAnimation(frameAnimator)
        
        let darkenScreen =  { self.blackView.alpha = Resources.VideoPlayer.backgroundDarker }
        let lightUpScreen =  { self.blackView.alpha = 0.0 }
        
        let blurAnimator = createPropertyAnimator(state: state,
                                                  onExpanded: darkenScreen(),
                                                  onCollapsed: lightUpScreen(),
                                                  duration: duration)
        startPropertyAnimation(blurAnimator)
        
        let animateCornerRadius = {
            self.videoPlayerVC.view.layer.cornerRadius = Resources.VideoPlayer.cornerRadiusAfterAnimation
        }
        
        let animateBackCornerRadius = {
            self.videoPlayerVC.view.layer.cornerRadius = Resources.VideoPlayer.cornerRadius
        }
        
        
        let cornerRadiusAnimator = createPropertyAnimator(state: state,
                                                          onExpanded: animateCornerRadius(),
                                                          onCollapsed: animateBackCornerRadius(),
                                                          duration: duration)
        startPropertyAnimation(cornerRadiusAnimator)
        
        frameAnimator.addCompletion { _ in
            self.bottomSheetVisible.toggle()
            self.runningAnimations.removeAll()
        }
    }
    
    private func continueInteractiveTransition() {
        for animation in runningAnimations {
            animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    private func createPropertyAnimator(state: BottomSheetState, onExpanded: @autoclosure @escaping () -> Void , onCollapsed: @autoclosure @escaping () -> Void, duration: TimeInterval, dampingRatio: CGFloat = 1) -> UIViewPropertyAnimator {
         let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1)
        
        propertyAnimator.addAnimations {
             switch state {
             case .expanded:
                 onExpanded()
             case .collapsed:
                 onCollapsed()
             }
         }
         return propertyAnimator
     }
     
     private func startPropertyAnimation(_ propertyAnimator: UIViewPropertyAnimator) {
         propertyAnimator.startAnimation()
         runningAnimations.append(propertyAnimator)
     }
}


extension YouTubeVideoListViewController {
    private func setupUI() {
        setupTableView()
        setupVideoPlayerVC()
        setupBlackView()
    }
    
    private func setupTableView() {
        tableView.register(TopBannerTableViewCell.nib(), forCellReuseIdentifier: TopBannerTableViewCell.reuseIdentifier)
        tableView.register(PlaylistTableViewCell.nib(), forCellReuseIdentifier: PlaylistTableViewCell.reuseIdentifier)
        tableView.register(SectionTitleTableViewCell.nib(), forCellReuseIdentifier: SectionTitleTableViewCell.reuseIdentifier)
        
        tableView.contentInset =  UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
    }
    
    private func setupVideoPlayerVC() {
        videoPlayerVC = YouTubeVideoPlayerViewController().initiateVCFromStoryboard()
        
        addChild(videoPlayerVC)
        
        let bottomScreen = self.view.frame.height - Resources.VideoPlayer.cardHandleAreaHeight
        
        videoPlayerVC.view.layer.cornerRadius = Resources.VideoPlayer.cornerRadius
        videoPlayerVC.view.frame = view.frame.inset(by: UIEdgeInsets(top: bottomScreen,
                                                                      left: Resources.VideoPlayer.padding,
                                                                      bottom: self.view.frame.height,
                                                                      right: Resources.VideoPlayer.padding))
        
        self.videoPlayerVC.view.frame.origin.y = bottomScreen
        
        videoPlayerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        view.addSubview(videoPlayerVC.view)
        
        videoPlayerVC.didMove(toParent: self)
        videoPlayerVC.view.clipsToBounds = true
        
        videoPlayerVC.dataSource = self
    }
    
    private func setupBlackView() {
                blackView = UIView()
                blackView.backgroundColor = .black
                blackView.alpha = 0
                blackView.frame = view.bounds
                view.insertSubview(blackView, belowSubview: videoPlayerVC.view)
    }
    
    @MainActor
    private func showTableView() async {
        self.activityIndicator.stopAnimating()
        self.tableView.reloadData()
        self.tableView.isHidden = false
    }
}

extension YouTubeVideoListViewController: YouTubeBannerPageViewControllerDelegate {
    func bannerClicked(playlistVideoID: String) {
        videoPlayerVC.loadVideoPlaylist(id: playlistVideoID)
    }
}

extension YouTubeVideoListViewController: PlaylistTableViewCellDelegate {
    func videoDidSelect(video: Video, positionInPlaylist: Int, playlistNumber: Int) {
        
        self.videoPositionInPlaylist = positionInPlaylist
        self.playlistNumber = playlistNumber
        
        videoPlayerVC.loadVideoWith(id: video.id)
        Task {
        await videoPlayerVC.configure(with: video)
        }
    }
}


extension YouTubeVideoListViewController: YouTubeVideoPlayerDataSource {
    func numbersOfVideosInPlaylist(position: Int) -> Int {
        return videos[playlistNumber].count
    }
    
    func getVideo(position: Int) -> Video {
        let video = videos[playlistNumber][position]
        return video
    }

    func getCurrentVideoPositionInPlaylist() -> Int {
        return videoPositionInPlaylist
    }
    

}
