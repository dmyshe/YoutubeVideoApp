//
//  SectionTitleTableViewCell.swift
//  YoutubeApp
//
//  Created by Дмитро  on 25.08.2022.
//

import UIKit

class SectionTitleTableViewCell: UITableViewCell {
    @IBOutlet  weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.text = nil
    }
}
