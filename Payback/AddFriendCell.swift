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
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var user: User? {
        didSet {
            updateLabels()
        }
    }
    
    override func awakeFromNib() {
        self.sendRequestButton.layer.cornerRadius = self.sendRequestButton.bounds.size.width / 2
        self.sendRequestButton.layer.masksToBounds = true
    }
    
    @IBAction func sendRequest(sender: AnyObject) {
        let queryUserGroup = dispatch_group_create()
        let addFriendGroup = dispatch_group_create()
        
        let request: FriendRequest = FriendRequest()
        
        activityIndicator.center = self.window!.rootViewController!.view.center
        self.window!.rootViewController!.view.addSubview(activityIndicator)
        self.window!.rootViewController!.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.color = UIColor.grayColor()
        self.activityIndicator.startAnimating()
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
                
                dispatch_group_enter(addFriendGroup)
                request.save().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                    if task.error() == nil {
                    
                    } else {
                    
                    }
                    dispatch_group_leave(addFriendGroup)
                    return nil;
                })

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                    dispatch_group_wait(addFriendGroup, DISPATCH_TIME_FOREVER)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.addFriendViewController.checkForPendingRequests()
                        self.activityIndicator.stopAnimating()
                    })
                })
            })
        })
    }
    
    func updateLabels() {
        
        if let user = self.user {
            user.fetchIfNecessary().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                self.nameLabel.text = user.name
                return nil;
            })
        }
    }

    
}