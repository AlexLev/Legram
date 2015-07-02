//
//  FirstViewController.swift
//  Legram
//
//  Created by Алексей Левинтов on 28.06.15.
//  Copyright (c) 2015 Алексей Левинтов. All rights reserved.
//

import UIKit
import ParseUI
import Parse
class FirstViewController: PFQueryTableViewController, PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate {

    var isViewLoaded:Bool? = false
    required init(coder aDecoder: NSCoder!)  {
        super.init(coder: aDecoder)

        self.parseClassName = "Content";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = "text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
         self.imageKey = "image";
        self.queryForTable()
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = true;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = true;
        
        // The number of objects to show per page
        self.objectsPerPage = 20;


    }
    override func queryForTable() -> PFQuery {
        if let isLoaded = isViewLoaded {
            
            if !isLoaded {
                
            } else {
                let followingActivitiesPredicate = NSPredicate(format: "fromUser = %@ and type = %@", PFUser.currentUser()!, "follow")
                let followingActivitiesQuery = PFQuery(className: "Activity", predicate: followingActivitiesPredicate)
                
                
                let photosFromFollowedUsersQuery = PFQuery(className: self.parseClassName!, predicate: nil)
                photosFromFollowedUsersQuery.whereKey("fromUser", matchesKey: "toUser", inQuery: followingActivitiesQuery)

                
                
                let photosFromCurrentUserQuery = PFQuery(className: self.parseClassName!, predicate: nil)
                photosFromCurrentUserQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)

                let query = PFQuery.orQueryWithSubqueries([photosFromFollowedUsersQuery, photosFromCurrentUserQuery])
                query.includeKey("fromUser")
                query.orderByDescending("createdAt")
                return query
            }
        } else {
            
        }
        let followingActivitiesPredicate = NSPredicate(format: "type = %@", "follwwow")
        let query = PFQuery(className: self.parseClassName!, predicate: followingActivitiesPredicate)
        query.includeKey("fromUser")
        return query
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        println(error)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentCell")
        isViewLoaded = true
        self.loadObjects()
//        self.view.addSubview(UINavigationController(rootViewController: self).view)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        let user = PFUser.currentUser()
        if user!.objectId  == nil
        {
            
            // other fields can be set just like with PFObject
            let vc = PFLogInViewController()
            vc.delegate = self
            vc.navigationItem.leftBarButtonItem = nil
            vc.signUpController?.delegate = self
            NSLog("\(self.tabBarController)")
            
            self.presentViewController(vc, animated: false, completion: nil)
        } else {
            let user = PFUser.currentUser()
            //            PFUser.logOut()
            user?.fetchInBackgroundWithBlock({ (userNew, error) -> Void in
                
            })
            //            loadUsers()
//            self.title = user?.username;
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        logInController.dismissViewControllerAnimated(true, completion: { () -> Void in
            let user = PFUser.currentUser()
//            self.loadUsers()
//            self.title = user?.username;
        })
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.width + 120;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ContentTableViewCell? = nil
        if let  x = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as? ContentTableViewCell
        {
            cell = x
        } else {
            cell = ContentTableViewCell()
        }
        if (self.objects?.count > indexPath.row){
            let object = self.objects![indexPath.row] as! PFObject
            cell?.contenTextLabel.text = object.objectForKey("text") as? String
            let file = object.objectForKey("image") as? PFFile
            cell?.contentImageView.file = file
            cell?.contentImageView.loadInBackground({ (image, error) -> Void in
                cell?.contentImageView.contentMode = UIViewContentMode.ScaleAspectFill
            })
            if let user = object.objectForKey("fromUser") as? PFUser {
                println("\(user.allKeys())")
                
                if let name = user.username {
                    NSLog("\(name)")
                    cell?.userNameButton.setTitle(name, forState: UIControlState.Normal)
                }
            } else {
                println("\(object.allKeys())")
            }
            cell?.likeButton.setTitle("0", forState: UIControlState.Normal)
            let timeInterval = object.createdAt?.timeIntervalSinceNow
            if timeInterval > -60 * 60 {
                cell?.timeLabel.text = "\(-Int(timeInterval! / 60)) минут назад"
            } else {
                cell?.timeLabel.text = NSDateFormatter.localizedStringFromDate(object.createdAt!,
                    dateStyle: .MediumStyle,
                    timeStyle: .MediumStyle)
            }
            NSLog("\(cell?.likeButton.titleLabel?.text)")
            if let likes = LikesUtility.getLikesForContent(object) {
                cell?.likeButton.setTitle("\(likes.count)", forState: UIControlState.Normal)
            } else {
                LikesUtility.loadLikesForContent(object, result: { (result) -> () in
                    if let res = result {
                        NSLog("\(res)")
                        cell?.likeButton.setTitle("\(res.count)", forState: UIControlState.Normal)
                        cell?.setNeedsLayout()
                    }
                })
            }
            
            cell?.like = {() ->() in
                LikesUtility.likeDislikeContent(object, result: { (liked) -> () in
                    if let likes = LikesUtility.getLikesForContent(object) {
                        cell?.likeButton.setTitle("\(likes.count)", forState: UIControlState.Normal)
                        cell?.setNeedsLayout()
                    }
                })
//                let like = PFObject(className: "Activity", dictionary: ["fromUser" : PFUser.currentUser()!, "type":"like", "content":object])
//                like.saveInBackgroundWithBlock({ (successed, error) -> Void in
//                    if successed {
//
//                    }
//                    NSLog("\(error)")
//                })
                NSLog("%@", indexPath)
            }
            cell?.user = {()->() in
                if let user = object.objectForKey("fromUser") as? PFUser {
//                    println("\(user.allKeys())")
                    
                    if let name = user.username {
                        
                        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        var vc = storyboard.instantiateViewControllerWithIdentifier("userProfile") as! SecondViewController
                        var object = self.objects![indexPath.row] as! PFObject
                        vc.user = user
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        return cell!
    }
    @IBAction func addContent(sender: AnyObject) {
        var vc = AddContentViewController(nibName: "AddContentViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var vc = storyboard.instantiateViewControllerWithIdentifier("detailContent") as! ContentDetailTableViewController
        var object = self.objects![indexPath.row] as! PFObject
        vc.content = object
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


