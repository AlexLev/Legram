//
//  LikesUtility.swift
//  Legram
//
//  Created by Алексей Левинтов on 29.06.15.
//  Copyright (c) 2015 Алексей Левинтов. All rights reserved.
//

import UIKit
import Parse
class LikesUtility {
    static var items : [String:[PFObject]]!
    static func loadLikesForContent(content:PFObject, result:(([AnyObject]?)->())) {
//        NSLog("\(items)")
//        items[content.objectId!]

//            result(likes)
        if (items != nil) {
            if let likes = items[content.objectId!] {
                result(likes)
            } else {
//                items = [String:[PFObject]]()
                let predicate = NSPredicate(format: "content = %@ and type = %@", content, "like")
                let query = PFQuery(className: "Activity", predicate: predicate)
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    //                NSLog("\(objects) \(error)")
                    self.items[content.objectId!] = objects as? [PFObject]
                    result(objects)
                }
            }
        } else {
            items = [String:[PFObject]]()
            let predicate = NSPredicate(format: "content = %@ and type = %@", content, "like")
            let query = PFQuery(className: "Activity", predicate: predicate)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                //                NSLog("\(objects) \(error)")
                self.items[content.objectId!] = objects as? [PFObject]
                result(objects)
            }
        }
        
        
        
    }
    static func getLikesForContent(content:PFObject) -> [PFObject]? {
        if (items != nil) {
            if var likes = items[content.objectId!] {
                return likes
            } else {
                return nil
            }
        }
        return nil
    }
    static func likeDislikeContent(content:PFObject, result:((Bool)->())) {
        if getLikesForContent(content) != nil {
            if var likes = getLikesForContent(content) {
                for var i = 0; i < likes.count; i++ {
                    let object = likes[i]
                    let fromUser = object.objectForKey("fromUser") as? PFUser
                    println("\(fromUser?.objectId) ?= \(PFUser.currentUser()?.objectId!)")
                    if fromUser?.objectId! == PFUser.currentUser()?.objectId! {
                        object.deleteInBackgroundWithBlock({ (successed, error) -> Void in
                            if successed {
                                likes.removeAtIndex(i)
                                self.items[content.objectId!] = likes
                                result(false)
                            }
                        })
                        return
                    }
                }
               
                let like = PFObject(className: "Activity", dictionary: ["fromUser" : PFUser.currentUser()!, "type":"like", "content":content])
                like.saveInBackgroundWithBlock({ (successed, error) -> Void in
                    if successed {
                        likes.append(like)
                        self.items[content.objectId!] = likes
                        result(true)
                    }
                    NSLog("\(error)")
                })
                
            }
        } else {
            let like = PFObject(className: "Activity", dictionary: ["fromUser" : PFUser.currentUser()!, "type":"like", "content":content])
            like.saveInBackgroundWithBlock({ (successed, error) -> Void in
                if successed {
                    self.items[content.objectId!] = [like]
                    result(true)
                }
                NSLog("\(error)")
            })
        }
    }
    static func staticMethod() {
        items.removeAll(keepCapacity: false)
    }
}
