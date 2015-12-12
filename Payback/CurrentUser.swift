//
//  CurrentUser.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

// Typical Singleton Pattern to Store Current User Info

import UIKit

class CurrentUser {
    
    static var sharedInstance = CurrentUser();
    
    private var user: User?;
    
    internal var currentUser: User? {
        get {
            return self.user;
        }
        set (value) {
            self.user = value;
        }
    }
    
    private init()
    {
        
    }
    
    
    
}