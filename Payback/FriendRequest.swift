//
//  FriendRequest.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class FriendRequest : IBMDataObject, IBMDataObjectSpecialization {

    // MARK: Database Fields
    
    @NSManaged var fromUser: User
    
    @NSManaged var fromName: String
    
    @NSManaged var fromEmail: String
    
    @NSManaged var toUser: User
    
    @NSManaged var toName: String
    
    @NSManaged var toEmail: String
    
    @NSManaged var accepted: Bool
    
    // MARK:- Setup
    required override init() {
        super.init()
    }
    
    override init!(withClass classname: String!) {
        super.init(withClass:"FriendRequest")
    }
    
    // IBM Subclass Requirements
    class func dataClassName() -> String {
        return "FriendRequest"
    }
    
    class func makeFriendRequest(from: User, to: User) {
        let request = FriendRequest()
        request.toUser = to
        request.toName = to.name
        request.toEmail = to.email
        request.fromUser = from
        request.fromName = from.name
        request.fromEmail = from.email
        request.accepted = false
    }

    
}
