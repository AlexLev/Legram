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
        self.objectsPerPage = 5;
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "contentCell")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            print(user!.objectId)
            user?.fetchInBackgroundWithBlock({ (userNew, error) -> Void in
                
            })
            //            loadUsers()
            self.title = user?.username;
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
            self.title = user?.username;
        })
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 100
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
//        
//        var cell:ContentTableViewCell? = nil
//        if let  x = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as? ContentTableViewCell
//        {
//            cell = x
//        } else {
//            cell = ContentTableViewCell(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.width), reuseIdentifier: "contentCell")
//        }
//        let object = self.objects![indexPath.row] as! PFObject
//        cell?.contentImageView.file = object.objectForKey("image") as? PFFile
//        return cell
//    }
}


