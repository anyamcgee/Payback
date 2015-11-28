//
//  User.swift
//  Payback
//
//  Created by Alice Fredine on 2015-11-28.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class User: IBMDataObject {

    var id: Int
    var name: String
    var photo: UIImage?
    
    init?(id: Int, name: String, photo: UIImage) {
        
        self.id = id
        self.name = name
        self.photo = photo
        
        super.init()
        
        if (name.isEmpty) {
            return nil
        }
    }
}
