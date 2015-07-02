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
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentImageView: PFImageView!
    var like: (() -> ())?
    var user: (() -> ())?
    @IBAction func likeAction(sender: AnyObject) {
        if let likeAction = like {
            likeAction()
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func userClick(sender: AnyObject) {
        if let userAction = user {
            userAction()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}
