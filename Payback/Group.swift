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
    
    // TODO: Figure out whether or not images are gonna be used, whether to make an enum, etc.
    /// The group's icon image
    @NSManaged var icon: UIImage
    
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
        newGroup.name = "Anya's Super Cool Group"
        newGroup.detail = "Only for super cool people"
        newGroup.save()
        print("Saved hopefully!")
    }
    
}
