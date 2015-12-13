//
//  Friendship.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class Friendship : IBMDataObject, IBMDataObjectSpecialization {
    
    // MARK:- Database Fields
    
    @NSManaged var firstUser: User
    @NSManaged var secondUser: User
    
    @NSManaged var firstUserEmail: String
    @NSManaged var secondUserEmail: String
    
    @NSManaged var firstUserScore: Float
    @NSManaged var secondUserScore: Float
    
    // MARK:- Setup
    required override init() {
        super.init()
    }
    
    override init!(withClass classname: String!) {
        super.init(withClass:"Friendship")
    }
    
    // IBM Subclass Requirements
    class func dataClassName() -> String {
        return "Friendship"
    }
    
    class func CreateFriendship(aUser: User, anotherUser: User) {
        let friends: Friendship = Friendship()
        friends.firstUser = aUser
        friends.secondUser = anotherUser
        friends.firstUserEmail = aUser.email
        friends.secondUserEmail = anotherUser.email
        friends.firstUserScore = 0.0
        friends.secondUserScore = 0.0
        friends.save()
    }

    
}
