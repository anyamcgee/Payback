//
//  FriendRequestCell.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class FriendRequestCell : UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var decline: UIButton!
    @IBOutlet weak var friendRequestViewController: FriendRequestsViewController!
    
    var request: FriendRequest? {
        didSet {
            updateLabels()
        }
    }
    
    @IBAction func declineRequest(sender: AnyObject) {
        self.request?.delete().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if (task.error() == nil) {
                print("Deleted request")
                self.friendRequestViewController.checkForRequests()
            }
            return nil;
        })
    }
    
    
    @IBAction func acceptRequest(sender: AnyObject) {
        let queryUserGroup = dispatch_group_create()
        let addFriendGroup = dispatch_group_create()
        
        let friendship: Friendship = Friendship()
        dispatch_group_enter(queryUserGroup)
        let query: IBMQuery = IBMQuery(forClass: "User")
        query.whereKey("email", equalTo: self.request?.fromEmail)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            let result = task.result() as? [User]
            if (result!.count > 0) {
                friendship.secondUser = result![0]
                friendship.secondUserEmail = result![0].email
                friendship.secondUserScore = 0.0
            }
            dispatch_group_leave(queryUserGroup)
            return nil;
        })
        
        friendship.firstUser = CurrentUser.sharedInstance.currentUser!
        friendship.firstUserEmail = CurrentUser.sharedInstance.currentUser!.email
        friendship.firstUserScore = 0.0
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(queryUserGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                print("Got user info")
                
                dispatch_group_enter(addFriendGroup)
                friendship.save().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                    if task.error() == nil {
                        print("saved successfully")
                    } else {
                        print(task.error())
                    }
                    dispatch_group_leave(addFriendGroup)
                    return nil;
                })
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                    dispatch_group_wait(addFriendGroup, DISPATCH_TIME_FOREVER)
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Saved new request")
                        self.request?.delete().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                            if (task.error() == nil) {
                                print("Deleted request")
                                self.friendRequestViewController.checkForRequests()
                            }
                            return nil;
                        })
                        
                    })
                })
            })
        })

    }
    
    
    func updateLabels() {
        if let request = self.request {
            request.fetchIfNecessary().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                self.name.text = request.fromName
                return nil;
            })
            
        }
    }
    
}
