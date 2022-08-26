//
//  YouTubeBannerPageViewController.swift
//  YoutubeApp
//
//  Created by Дмитро  on 18.08.2022.
//

import UIKit

protocol YouTubeBannerPageViewControllerDelegate : AnyObject {
    func bannerClicked(playlistVideoID: String)
}


class YouTubeBannerPageViewController: UIPageViewController {
    var pages: [UIViewController]  = []
    let pageControl = UIPageControl()
    var currentPage = 0 
    var timer: Timer?
    
    weak var bannerInfoDelegate: YouTubeBannerPageViewControllerDelegate?
    
    var currentPageVC: YouTubeBannerPageViewController {
        let bannerVC = (pages[currentPage] as! YouTubeBannerPageViewController)
        return bannerVC
    }
    
    private let youTubeService = YouTubeServiceAdapter(apiKey: YoutubeAPI.apiKey)
        
    var channel: [Channel]? = []
    
    private var channelExampleData = YoutubeChannelExample.exampleData
    
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
        fetchChannelInfo(withID: channelExampleData[currentPage].id)
        createTimer()
        addGestureRecognizer()
    }
    
    private func fetchChannelInfo(withID id: String) {
        Task.init {
            let newChannel = await youTubeService.getChannelInfo(channelID: id)
            await createBanner(with: newChannel)
        }
    }
}

//MARK: - YouTubeBannerVideoPageViewController
extension YouTubeBannerPageViewController {
    
    private func createTimer(withInterval interval: TimeInterval = 3.0) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.showNextPage()
        })
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
    }
    
    private func showNextPage() {

        print("PlaylistID",channelExampleData[currentPage].name)

        fetchChannelInfo(withID: channelExampleData[currentPage].id)
    }
    
    
    private func checkPages() {
        if  currentPage < pages.count - 1  {
            currentPage += 1
        }
        else {
            currentPage = 0
        }
    }
    
    private func setup() {
        dataSource = self
        view.layer.cornerRadius = Resources.PageBannerVC.cornerRadius
    }
    @MainActor
    private func createBanner(with channel: Channel) async {
        if pages.count < channelExampleData.count - 1 {
        let vc = YouTubeBannerViewController().initiateVCFromStoryboard()
        vc.channel = channel
        pages.append(vc)
        setViewControllers([pages[currentPage]], direction: .forward, animated: true, completion: nil)
        } else {
            setViewControllers([pages[currentPage]], direction: .forward, animated: true, completion: nil)
        }
        
        checkPages()
        pageControl.currentPage = currentPage
    }
    
    private func layout() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .black
        pageControl.numberOfPages = channelExampleData.count

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
        print("hello")
        let videoId = channelExampleData[currentPage].playlistID
        bannerInfoDelegate?.bannerClicked(playlistVideoID: videoId)
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

