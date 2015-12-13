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
    
    // User Paying Money
    @NSManaged var from: User
    
    // amount paid
    @NSManaged var amount: Float
    
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
    
    class func CreateTransaction(to: User, from: User, amount: Float) {
        let transaction = Transaction();
        transaction.to = to
        transaction.from = to
        transaction.amount = amount
        transaction.save()
    }

    
}
