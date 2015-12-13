//
//  FriendCell.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class FriendCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var friend: User? {
        didSet {
            updateLabels()
        }
    }
    
    var friendship: Friendship? {
        didSet {
            updateLabels()
        }
    }
    
    func updateLabels() {
        if let user = self.friend {
            self.nameLabel.text = user.name
            if let friendship = self.friendship {
                if (friendship.firstUserEmail == user.email) {
                    self.scoreLabel.text = "\(friendship.firstUserScore)"
                }
                else {
                    self.scoreLabel.text = "\(friendship.secondUserScore)"
                }
            }
        }
    }

}
