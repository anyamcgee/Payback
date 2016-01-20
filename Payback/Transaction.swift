//
//  Transaction.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class Transaction : IBMDataObject, IBMDataObjectSpecialization {
    
    // User Receiving Money
    @NSManaged var to: User
    
    // Email of User Receiving Money
    @NSManaged var toUserEmail: String
    
    // Name of User Receiving Money
    @NSManaged var toUserName: String
    
    // User Paying Money
    @NSManaged var from: User
    
    // Email of User Paying Money
    @NSManaged var fromUserEmail: String
    
    // Name of User Paying Money
    @NSManaged var fromUserName: String
    
    // amount paid
    @NSManaged var amount: Float
    
    // description of transaction
    @NSManaged var reason: String?
    
    
    // MARK:- Setup
    required override init() {
        super.init()
    }
    
    override init!(withClass classname: String!) {
        super.init(withClass:"Transaction")
    }
    
    // IBM Subclass Requirements
    class func dataClassName() -> String {
        return "Transaction"
    }
    
    class func CreateTransaction(to: User, from: User, amount: Float, description: String?, callback: (() -> Void)){
        let transaction = Transaction();
        transaction.to = to
        transaction.toUserEmail = to.email
        transaction.toUserName = to.name
        transaction.from = from
        transaction.fromUserEmail = from.email
        transaction.fromUserName = from.name
        transaction.amount = amount
        transaction.reason = description
        transaction.save()
        to.score -= abs(amount)
        from.score += abs(amount)
        to.save()
        from.save()
        var friendship: Friendship = Friendship()
        var toFirst: Bool = false
        let friendGroup = dispatch_group_create()
        let query = IBMQuery(forClass: "Friendship")
        dispatch_group_enter(friendGroup)
        query.whereKey("firstUserEmail", equalTo: to.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let result = task.result() as? [Friendship] {
                if (result.count > 0) {
                    for res in result {
                        if (res.secondUserEmail == from.email) {
                            friendship = res
                            toFirst = true;
                        }
                    }
                }
            }
            dispatch_group_leave(friendGroup)
            return nil;
        })
        
            dispatch_group_enter(friendGroup)
        let newQuery = IBMQuery(forClass: "Friendship")
            newQuery.whereKey("secondUserEmail", equalTo: to.email)
        print(to.email)
            newQuery.find().continueWithBlock({(task: BFTask!) -> BFTask! in
                if let result = task.result() as? [Friendship] {
                    if (result.count > 0) {
                        for res in result {
                            if (res.firstUserEmail == from.email) {
                                friendship = res
                                toFirst = false;
                            }
                        }
                    }
                }
                dispatch_group_leave(friendGroup)
                return nil;
            })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(friendGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                friendship.fetchIfNecessary().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                    if (toFirst) {
                        friendship.firstUserScore -= abs(amount)
                        friendship.secondUserScore += abs(amount)
                    }
                    else {
                        friendship.secondUserScore -= abs(amount)
                        friendship.firstUserScore += abs(amount)
                    }
                    friendship.save()
                    callback()
                    return nil;
                })
            })
        })
    }

}
