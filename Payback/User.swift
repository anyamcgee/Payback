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
    @NSManaged var id: Int
    
    // Username chosen by user
    @NSManaged var name: String
    
    // image chosen by user
    @NSManaged var photo: UIImage?
    
    // MARK:- Setup
    required override init() {
        super.init()
    }
    
    // TODO: Figure out where we store recent/all transactions. Endless scroll on transactions page?
    
    // TODO: Compute score based on owed and owing
    var score: Float {
        return 0.0
    }
    
    // TODO: Get all owed money and combine
    private var owed: Float {
        return 0.0
    }
    
    // TODO: Get all owing money and combine
    private var owing: Float {
        return 0.0
    }
    

    // IBM Subclass Requirements
    override class func dataClassName() -> String {
        return "user"
    }
}
