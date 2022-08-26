//
//  SectionTitleTableViewCell.swift
//  YoutubeApp
//
//  Created by Дмитро  on 25.08.2022.
//

import UIKit

class SectionTitleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "SectionTitleTableViewCell"

    @IBOutlet  weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.text = nil
    }

    
    static func nib() -> UINib {
        return UINib(nibName: "SectionTitleTableViewCell",
                     bundle: nil)
    }
}
