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
    
    class func CreateTransaction(to: User, from: User, amount: Float, description: String?){
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
        to.score += amount
        from.score -= amount
        var friendship: Friendship = Friendship()
        var doQuery: Bool = true
        var toFirst: Bool = false
        var query = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: to.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            let result = task.result() as? [Friendship]
            if (result!.count > 0) {
                friendship = result![0]
                doQuery = false;
                toFirst = true;
            }
            return nil;
        })
        
        if doQuery {
            query = IBMQuery()
            query.whereKey("secondUserEmail", equalTo: to.email)
            query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                let result = task.result() as? [Friendship]
                if (result!.count > 0) {
                    friendship = result![0]
                    doQuery = false;
                }
                return nil;
            })
        }
        
        friendship.fetchIfNecessary().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if (toFirst) {
                friendship.firstUserScore += amount
                friendship.secondUserScore -= amount
            }
            else {
                friendship.secondUserScore += amount
                friendship.firstUserScore -= amount
            }
            return nil;
        })
    }
    
    class func SaveFakeData()
    {
        let fromUser: User = CurrentUser.sharedInstance.currentUser!
        let toUser = User()
        toUser.email = "a.fake.email@email.com"
        toUser.name = "A Fake Name"
        toUser.id = "12345"
        self.CreateTransaction(toUser, from: fromUser, amount: 10.46, description: "Sushi")
        self.CreateTransaction(toUser, from: fromUser, amount: 40.00, description: "AirBnb")
        self.CreateTransaction(toUser, from: fromUser, amount: 52.50, description: "Christmas Present")
        self.CreateTransaction(toUser, from: fromUser, amount: 8.00, description: "Registration Fee")
        self.CreateTransaction(toUser, from: fromUser, amount: 10.00, description: nil)
        self.CreateTransaction(toUser, from: fromUser, amount: 5.00, description: "Coffee")
        self.CreateTransaction(fromUser, from: toUser, amount: 10.46, description: "Sushi")
        self.CreateTransaction(fromUser, from: toUser, amount: 40.00, description: "AirBnb")
        self.CreateTransaction(fromUser, from: toUser, amount: 52.50, description: "Christmas Present")
        self.CreateTransaction(fromUser, from: toUser, amount: 8.00, description: "Registration Fee")
        self.CreateTransaction(fromUser, from: toUser, amount: 10.00, description: nil)
        self.CreateTransaction(fromUser, from: toUser, amount: 2.00, description: "Coffee")
        
        
    }
}
