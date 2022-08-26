//
//  PlaylistTableViewCell.swift
//  YoutubeApp
//
//  Created by Дмитро  on 20.08.2022.
//

import UIKit
import Foundation

protocol PlaylistTableViewCellDelegate: AnyObject {
    func videoDidSelect(video: Video, positionInPlaylist: Int, playlistNumber: Int)
}

class PlaylistTableViewCell: UITableViewCell {
    static let reuseIdentifier = "PlaylistTableViewCell"
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    weak var delegate: PlaylistTableViewCellDelegate?
    
    var videos = [Video]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    enum CellSize {
    case small,large
    }
    
    var currentCellSize: CellSize = .small
    
    func configure(cellSize : CellSize) {
        currentCellSize = cellSize
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(VideoCollectionCell.nib(), forCellWithReuseIdentifier: VideoCollectionCell.reuseIdentifier)      
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset =  UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }

    static func nib() -> UINib {
        return UINib(nibName: "PlaylistTableViewCell",
                     bundle: nil)
    }
}

//MARK: - UICollectionViewDelegate
extension PlaylistTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentVideo = videos[indexPath.row]
        delegate?.videoDidSelect(video: currentVideo, positionInPlaylist: indexPath.row, playlistNumber: collectionView.tag)
        print(indexPath.row)
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension PlaylistTableViewCell: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionCell.reuseIdentifier, for: indexPath) as! VideoCollectionCell
        
        let currentVideo = videos[indexPath.row]

        cell.configure(video: currentVideo)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch currentCellSize {
            
        case .small:
            return CGSize(width: collectionView.bounds.width / 2.4, height: collectionView.bounds.height - 1)
        case .large:
            return   CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.height - 5)
        }
    }
}
