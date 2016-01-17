//
//  FriendRequest.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class FriendRequest : IBMDataObject, IBMDataObjectSpecialization {

    // MARK: Database Fields
    
    @NSManaged var fromUser: User
    
    @NSManaged var fromName: String
    
    @NSManaged var fromEmail: String
    
    @NSManaged var toUser: User
    
    @NSManaged var toName: String
    
    @NSManaged var toEmail: String
    
    @NSManaged var accepted: Bool
    
    // MARK:- Setup
    required override init() {
        super.init()
    }
    
    override init!(withClass classname: String!) {
        super.init(withClass:"FriendRequest")
    }
    
    // IBM Subclass Requirements
    class func dataClassName() -> String {
        return "FriendRequest"
    }
    
    class func makeFriendRequest(from: User, to: User) {
        let request = FriendRequest()
        request.toUser = to
        request.toName = to.name
        request.toEmail = to.email
        request.fromUser = from
        request.fromName = from.name
        request.fromEmail = from.email
        request.accepted = false
        request.save()
    }
    
    class func checkFriendRequests(user: User, callback: (results: [FriendRequest]?) -> Void) {
        let query: IBMQuery = IBMQuery(forClass: "FriendRequest")
        query.whereKey("toEmail", equalTo: user.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let result = task.result() as? [FriendRequest] {
                callback(results: result)
            }
            return nil;
        })

    }
    
    class func checkUserHasFriendRequests(user: User) {
        var hasFriends: Bool = false;
        let friendGroup = dispatch_group_create()
        dispatch_group_enter(friendGroup)
        checkFriendRequests(user, callback: {(results: [FriendRequest]?) -> Void in
            if (results?.count > 0) {
                hasFriends = true;
            }
            dispatch_group_leave(friendGroup)
        })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(friendGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                return hasFriends
            })
        })
    }

    
}
