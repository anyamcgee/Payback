//
//  Group.swift
//  Payback
//
//  Created by Anya McGee on 2015-11-25.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class Group: IBMDataObject, IBMDataObjectSpecialization {
    
    // MARK:- Database Properties
    
    /// The name of the group
    @NSManaged var name: String
    
    /// A more detailed description of the group
    @NSManaged var detail: String
    
    @NSManaged var author: User
    
    /// Just the name of a local icon I think is easiest (Let's not save files to IBM)
    @NSManaged var icon: String?
    
    // TODO: Figure out how to store the balances. (Join table? Dict? Relation?)
    
    // MARK:- Computed Properties
    
    // TODO: After balances are loaded, change this to compute overall group balance
    @NSManaged var balance: Float
    
    // MARK:- Setup
    
    required override init() {
        super.init()
    }
    
    override init!(withClass classname: String!) {
        super.init(withClass:"Group")
    }
    
    /// Required IBMData subclassing, returns a string corresponding to the name of the table in the database
    class func dataClassName() -> String {
        return "Group"
    }
    
    class func recalculateBalances(users: [UserGroupInfo], transaction: GroupTransaction) -> String {
        let newAmount = transaction.amount
        if newAmount < 0 {
            for userInfo in users {
                userInfo.balance += newAmount / Float(users.count)
                if userInfo.user.objectId.isEqual(transaction.user.objectId) {
                    userInfo.balance -= newAmount
                }
            }
        } else if newAmount > 0 {
            
            var paidUsers = [(String, Float)]()
            var remainingBalance = newAmount
            
            for userInfo in users {
                if userInfo.user.email.isEqual(transaction.user.email) {
                    userInfo.balance += newAmount
                } else if userInfo.balance > 0 {
                    let payAmount = min(remainingBalance, userInfo.balance)
                    userInfo.balance -= payAmount
                    remainingBalance -= payAmount
                    paidUsers.append((userInfo.username ?? "", payAmount))
                }
            }
        }
        for user in users {
            CurrentUser.sharedInstance.updateUserInfo(user)
            user.save().continueWithBlock({(task: BFTask!) -> BFTask! in
                return nil
            })
        }
        return ""
    }
    
    class func saveATestObject() {
        var newGroup = Group()
        newGroup.name = "Fidel's Hideaway"
        newGroup.detail = "🐠🐠🐠"
        newGroup.save()
        print("Saved hopefully!")
    }
    
}
