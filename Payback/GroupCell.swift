//
//  GroupCell.swift
//  Payback
//
//  Created by Anya McGee on 2015-11-25.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    
    // MARK:- Properties
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var group: Group? {
        didSet {
            updateLabels()
        }
    }
    
    // MARK- Setup
    
    func updateLabels() {
        if let group = self.group {
            if let iconName = group.icon {
                self.iconImageView.image = UIImage(named: iconName)
            }
            self.nameLabel.text = group.name
            self.balanceLabel.text = "\(group.balance)"
            if group.balance < 0 {
                self.balanceLabel.textColor = Style.red
            } else {
                self.balanceLabel.textColor = Style.mediumGreen
            }
        }
    }

}
