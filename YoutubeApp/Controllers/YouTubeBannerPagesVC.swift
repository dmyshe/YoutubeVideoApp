//
//  YouTubeBannerPageViewController.swift
//  YoutubeApp
//
//  Created by Дмитро  on 18.08.2022.
//

import UIKit

protocol YouTubeBannerPageViewControllerDelegate : AnyObject {
    func bannerClicked(playlistVideos: [Video])
}


class YouTubeBannerPageViewController: UIPageViewController {
    var pages: [UIViewController]  = []
    
    private let pageControl = UIPageControl()
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
    private var timer: Timer?
    
    weak var bannerInfoDelegate: YouTubeBannerPageViewControllerDelegate?
    
    
    private let youTubeService = YouTubeServiceAdapter(apiKey: YoutubeAPI.apiKey)
    
    var channels: [Channel]? = []
    
    var exampleData = [Channel]()
    
    private var videos = [[Video]]()
    private var playlists = [Playlist]()
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        fetchChannelInfo2()
        createTimer()
        addGestureRecognizer()
    }
    
    private func fetchChannelInfo2() {
        Task(priority: .userInitiated) {
            let id = exampleData[currentPage].id
            let newChannel = await youTubeService.getChannelInfo(channelID: id)
            let playlist = await youTubeService.getVideoPlaylists(withChannelID: id)
            let videos = await youTubeService.getPlaylistVideos(withPlaylistID: playlist[0].id)
            
            await MainActor.run {
                add(channel: newChannel, playlists: playlist, playlistVideos1: videos)
                createBanner(with: exampleData[currentPage])
            }
        }
    }
    
    func add(channel: Channel, playlists: [Playlist], playlistVideos1: [Video]) {
        exampleData[currentPage] = channel
        self.playlists = playlists
        self.videos.append(playlistVideos1)
        
        self.playlists[currentPage].videos = videos[videos.count - 1]
        
        exampleData[currentPage].videoPlaylists = self.playlists
    }
}

//MARK: - YouTubeBannerVideoPageViewController
extension YouTubeBannerPageViewController {
    
    private func createTimer(withInterval interval: TimeInterval = 5.0) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.showNextPage()
        })
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
    }
    
    private func showNextPage() {
        guard pages.count != exampleData.count else {
            print("don't download")
            setNextPage()
            return
        }
        
        fetchChannelInfo2()
        
    }
    
    private func setNextPage() {
        if currentPage > exampleData.count - 1 {
            currentPage = 0
        }
        setViewControllers([pages[currentPage]], direction: .forward, animated: true, completion: nil)
        checkCurrentPages()
        
    }
    
    
    private func checkCurrentPages() {
        if currentPage > exampleData.count - 1 {
            currentPage = 0
        } else {
            currentPage += 1
        }
    }
    
    private func setup() {
        dataSource = self
        view.layer.cornerRadius = Resources.PageBannerVC.cornerRadius
    }
    
    
    private func createBanner(with channel: Channel)   {
        let vc = YouTubeBannerViewController().initiateVCFromStoryboard()
        vc.channel = channel
        pages.append(vc)
        setNextPage()
    }
    
    private func layout() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = Resources.PageBannerVC.pageControlDotsBGColor
        pageControl.currentPage = 0
        pageControl.numberOfPages = 4
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 15),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 1),
        ])
    }
    
    private func addGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openVideo(recognizer:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func openVideo(recognizer: UIPanGestureRecognizer) {
        let index: Int = currentPage - 1
        
        let currentPlaylistVideos = videos[index]
        
        bannerInfoDelegate?.bannerClicked(playlistVideos: currentPlaylistVideos )
    }
}

// MARK: - UIPageViewControllerDataSource
extension YouTubeBannerPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        if currentIndex == 0 {
            return pages.last
        } else {
            return pages[currentIndex - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex < pages.count - 1 {
            return pages[currentIndex + 1]
        } else {
            return pages.first
        }
    }
}

