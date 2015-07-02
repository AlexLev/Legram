//
//  SecondViewController.swift
//  Legram
//
//  Created by Алексей Левинтов on 28.06.15.
//  Copyright (c) 2015 Алексей Левинтов. All rights reserved.
//

import UIKit
import ParseUI
import Parse
class SecondViewController: UIViewController {
    var user:PFUser? = nil
    var followed:Bool = false
    var followActivity: PFObject? = nil
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        followButton.hidden = true
        if user == nil {
           user = PFUser.currentUser()
        } else {
            if user?.objectId != PFUser.currentUser()?.objectId {
                isFollowed()
            }
        }
        userLabel.text = user?.username
        // Do any additional setup after loading the view, typically from a nib.
    }
    func isFollowed() {
        let predicate = NSPredicate(format: "fromUser = %@ and toUser = %@ and type = %@", PFUser.currentUser()!, user!, "follow")
        let query = PFQuery(className: "Activity", predicate: predicate)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            //                NSLog("\(objects) \(error)")
            if objects?.count == 0 {
                self.followButton.hidden = false
                self.followed = false
                self.followButton.setTitle("Подписаться", forState: UIControlState.Normal)
            } else {
                let object: AnyObject? = objects?[0]
                self.followActivity = object as? PFObject
                self.followButton.hidden = false
                self.followed = true
                self.followButton.setTitle("Отписаться", forState: UIControlState.Normal)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func followAction(sender: AnyObject) {
        if !followed {
            let activity = PFObject(className: "Activity", dictionary: ["fromUser" : PFUser.currentUser()!, "type":"follow","toUser":user!])
            activity.saveInBackgroundWithBlock({ (successed, error) -> Void in
                if successed {
                    self.followed = true
                    self.followButton.setTitle("Отписаться", forState: UIControlState.Normal)
                    self.followActivity = activity
                }
                println(successed)
                println(error)
            })
        } else {
            self.followActivity?.deleteInBackgroundWithBlock({ (successed, error) -> Void in
                if successed {
                    self.followed = false
                    self.followButton.setTitle("Подписаться", forState: UIControlState.Normal)
                    self.followActivity = nil
                }
            })
        }
    }

}

