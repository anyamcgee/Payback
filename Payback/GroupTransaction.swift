//
//  GroupTransaction.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class GroupTransaction : IBMDataObject, IBMDataObjectSpecialization {
    
    // User Receiving Money
    @NSManaged var group: Group
    
    // User Paying Money
    @NSManaged var user: User
    
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
        super.init(withClass:"GroupTransaction")
    }
    
    // IBM Subclass Requirements
    class func dataClassName() -> String {
        return "GroupTransaction"
    }
    
}
