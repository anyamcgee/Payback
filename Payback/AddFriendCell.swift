//
//  AddFriendCell.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class AddFriendCell : UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var addFriendViewController: AddFriendsViewController!
    
    var user: User? {
        didSet {
            updateLabels()
        }
    }
    
    @IBAction func sendRequest(sender: AnyObject) {
        let queryUserGroup = dispatch_group_create()
        let addFriendGroup = dispatch_group_create()
        
        let request: FriendRequest = FriendRequest()
        
        dispatch_group_enter(queryUserGroup)
        let query: IBMQuery = IBMQuery(forClass: "User")
        query.whereKey("email", equalTo: user?.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            let result = task.result() as? [User]
            if (result!.count > 0) {
                request.toUser = result![0]
                request.toName = result![0].name
                request.toEmail = result![0].email
            }
            dispatch_group_leave(queryUserGroup)
            return nil;
        })
        
        request.fromUser = CurrentUser.sharedInstance.currentUser!
        request.fromName = CurrentUser.sharedInstance.currentUser!.name
        request.fromEmail = CurrentUser.sharedInstance.currentUser!.email
        request.accepted = false
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(queryUserGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                print("Got user info")
                
                dispatch_group_enter(addFriendGroup)
                request.save().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
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
                        self.addFriendViewController.checkForAlreadyFriends()
                    })
                })
            })
        })
    }
    
    func updateLabels() {
        
        if let user = self.user {
            self.nameLabel.text = user.name
        }
    }

    
}