//
//  GroupUserInfo.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

/// A join table-like object that associates a user with a group, and stores the balance of that user in the group
class GroupUserInfo:  IBMDataObject, IBMDataObjectSpecialization  {
    
    @NSManaged var group: Group
    @NSManaged var user: User
    @NSManaged var balance: Float
    
    // MARK:- Setup
    
    required override init() {
        super.init()
    }
    
    override init!(withClass classname: String!) {
        super.init(withClass:"GroupUserInfo")
    }
    
    /// Required IBMData subclassing, returns a string corresponding to the name of the table in the database
    class func dataClassName() -> String {
        return "GroupUserInfo"
    }
    
}
