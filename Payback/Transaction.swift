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
    @NSManaged var toEmail: String
    
    // User Paying Money
    @NSManaged var from: User
    
    
    // Email of User Paying Money
    @NSManaged var fromEmail: String
    
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
        transaction.toEmail = to.email
        transaction.from = from
        transaction.fromEmail = from.email
        transaction.amount = amount
        transaction.reason = description
        transaction.save()
    }
    
    class func SaveFakeData()
    {
        let user: User = CurrentUser.sharedInstance.currentUser!
        self.CreateTransaction(user, from: user, amount: 10.46, description: "Sushi")
        self.CreateTransaction(user, from: user, amount: 40.00, description: "AirBnb")
        self.CreateTransaction(user, from: user, amount: 52.50, description: "Christmas Present")
        self.CreateTransaction(user, from: user, amount: 8.00, description: "Registration Fee")
        self.CreateTransaction(user, from: user, amount: 10.00, description: nil)
        self.CreateTransaction(user, from: user, amount: 5.00, description: "Coffee")
        
    }
}
