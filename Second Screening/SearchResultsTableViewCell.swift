//
//  SearchResultsTableViewCell.swift
//  Second Screening
//
//  Created by Sinan Demirci on 19.05.18.
//  Copyright © 2018 Sinan Demirci. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var mediaTitle: UITextView!
    @IBOutlet weak var episodeTitle: UITextView!
    @IBOutlet weak var subtitleTitle: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
