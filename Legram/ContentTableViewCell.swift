//
//  ContentTableViewCell.swift
//  Legram
//
//  Created by Алексей Левинтов on 28.06.15.
//  Copyright (c) 2015 Алексей Левинтов. All rights reserved.
//

import UIKit
import ParseUI
import Parse
class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var contenTextLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
