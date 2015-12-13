//
//  UserTableViewCell.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            updateLabels()
        }
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK- Setup
    
    func updateLabels() {
        if let user = self.user {
            self.nameLabel.text = user.name
        }
    }
    
}
