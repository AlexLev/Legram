//
//  ContentDetailTableViewController.swift
//  Legram
//
//  Created by Алексей Левинтов on 01.07.15.
//  Copyright (c) 2015 Алексей Левинтов. All rights reserved.
//

import UIKit
import ParseUI
import Parse
class ContentDetailTableViewController: PFQueryTableViewController, UITextFieldDelegate {
    var content:PFObject = PFObject(className: "Content")
    required init(coder aDecoder: NSCoder!)  {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Activity";

        // The key of the PFObject to display in the label of the default cell style
        self.textKey = "text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
//        self.imageKey = "image";
        self.queryForTable()
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = true;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = true;
        
        // The number of objects to show per page
        self.objectsPerPage = 20;
        
    }
    override func queryForTable() -> PFQuery {
        let predicate = NSPredicate(format: "content = %@ and type = %@", content, "comment")
        
        return PFQuery(className: "Activity", predicate: predicate)
    }
    @IBAction func addComent(sender: AnyObject) {
        let view = UITextField(frame: CGRectMake(0, 0, self.view.frame.size.width - 60, 60))
        view.backgroundColor = UIColor.whiteColor()
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true

        view.delegate = self
        let hover = UIButton(frame: self.view.window!.frame)
        hover.addTarget(self, action: "hideSender:", forControlEvents: UIControlEvents.TouchUpInside)
        hover.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        hover.addSubview(view)
        view.center = CGPointMake(hover.frame.width / 2, hover.frame.height / 2)
        self.view.window?.addSubview(hover)
    }
    func hideSender(sender: AnyObject) {
        if let view = sender as? UIView {
            view.removeFromSuperview()
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let comment = PFObject(className: "Activity", dictionary: ["fromUser" : PFUser.currentUser()!, "type":"comment", "content":content, "text":textField.text])
        comment.saveInBackgroundWithBlock { (successed, error) -> Void in
            self.loadObjects()
            textField.superview?.removeFromSuperview()
        }
        
        
        return true
    }

    @IBOutlet weak var addComent: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(self.view.frame.width + 120, 0, 0, 0)
        var view = UINib(nibName: "ContentTableViewCell", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil)[0] as? ContentTableViewCell

        view!.contenTextLabel.text = content.objectForKey("text") as? String
        let file = content.objectForKey("image") as? PFFile
        view!.contentImageView.file = file
        view!.contentImageView.loadInBackground({ (image, error) -> Void in
            view!.contentImageView.contentMode = UIViewContentMode.ScaleAspectFill
        })
        if let user = content.objectForKey("fromUser") as? PFUser {
            println("\(user.allKeys())")
            
            if let name = user.username {
                NSLog("\(name)")
                view!.userNameButton.setTitle(name, forState: UIControlState.Normal)
            }
        } else {
            println("\(content.allKeys())")
        }
        view!.likeButton.setTitle("0", forState: UIControlState.Normal)
        let timeInterval = content.createdAt?.timeIntervalSinceNow
        if timeInterval > -60 * 60 {
            view!.timeLabel.text = "\(-Int(timeInterval! / 60)) минут назад"
        } else {
            view!.timeLabel.text = NSDateFormatter.localizedStringFromDate(content.createdAt!,
                dateStyle: .MediumStyle,
                timeStyle: .MediumStyle)
        }
        NSLog("\(view!.likeButton.titleLabel?.text)")
        if let likes = LikesUtility.getLikesForContent(content) {
            view!.likeButton.setTitle("\(likes.count)", forState: UIControlState.Normal)
        } else {
            LikesUtility.loadLikesForContent(content, result: { (result) -> () in
                if let res = result {
                    NSLog("\(res)")
                    view!.likeButton.setTitle("\(res.count)", forState: UIControlState.Normal)
                    view!.setNeedsLayout()
                }
            })
        }
        
        view!.like = {() ->() in
            LikesUtility.likeDislikeContent(self.content, result: { (liked) -> () in
                if let likes = LikesUtility.getLikesForContent(self.content) {
                    view!.likeButton.setTitle("\(likes.count)", forState: UIControlState.Normal)
                    view!.setNeedsLayout()
                }
            })
            //                let like = PFObject(className: "Activity", dictionary: ["fromUser" : PFUser.currentUser()!, "type":"like", "content":object])
            //                like.saveInBackgroundWithBlock({ (successed, error) -> Void in
            //                    if successed {
            //
            //                    }
            //                    NSLog("\(error)")
            //                })
        }
        view!.user = {()->() in
            if let user = self.content.objectForKey("fromUser") as? PFUser {
                //                    println("\(user.allKeys())")
                
                if let name = user.username {
                    
                    var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    var vc = storyboard.instantiateViewControllerWithIdentifier("userProfile") as! SecondViewController
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        view?.backgroundColor = UIColor.whiteColor()
        view?.frame = CGRectMake(0, -self.view.frame.width - 120, self.view.frame.size.width, self.view.frame.width + 120)
        self.view.addSubview(view!)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
