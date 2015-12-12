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
    
    /// An array containing references to all users that are group members
    @NSManaged var users: [User]
    @NSManaged var author: User
    
    /// Just the name of a local icon I think is easiest (Let's not save files to IBM)
    @NSManaged var icon: String?
    
    // TODO: Figure out how to store the balances. (Join table? Dict? Relation?)
    
    // MARK:- Computed Properties
    
    // TODO: After balances are loaded, change this to compute overall group balance
    var balance: Int {
        return 10
    }
    
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
    
    class func saveATestObject() {
        var newGroup = Group()
        newGroup.name = "Fidel's Hideaway"
        newGroup.detail = "🐠🐠🐠"
        newGroup.save()
        print("Saved hopefully!")
    }
    
}
