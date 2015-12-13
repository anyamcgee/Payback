//
//  User.swift
//  Payback
//
//  Created by Alice Fredine on 2015-11-28.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class User: IBMUser {

    // MARK: Database Properties
    
    // TODO: Figure out if we need this separately from IBMUser uuid
    @NSManaged var id: String
    
    // Username chosen by user
    @NSManaged var name: String
    
    // email set by Google Sign In
    @NSManaged var email: String
    
    // Overall user score of money owed versus owing
    @NSManaged var score: Float
    
    // MARK:- Setup
    required override init() {
        super.init()
    }
    
    override init!(withClass classname: String!) {
        super.init(withClass:"User")
    }
    
    // IBM Subclass Requirements
    override class func dataClassName() -> String {
        return "User"
    }

    
    // TODO: Get all owed money and combine
    private var owed: Float {
        return 0.0
    }
    
    // TODO: Get all owing money and combine
    private var owing: Float {
        return 0.0
    }
   
}
