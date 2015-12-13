//
//  TableViewCell.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    var userInfo: UserGroupInfo? {
        didSet {
            updateLabels()
        }
    }
    
    func updateLabels() {
        if let userInfo = self.userInfo {
            self.nameLabel.text = userInfo.username ?? ""
            self.balanceLabel.text = "\(userInfo.balance)"
            if userInfo.balance < 0 {
                self.balanceLabel.textColor = Style.red
            } else {
                self.balanceLabel.textColor = Style.mediumGreen
            }
        }
    }
    
    class func getTotalBalance(info: [UserGroupInfo]) -> Float {
        return info.reduce(0, combine: { (last: Float, next: UserGroupInfo) in return last + next.balance })
    }

}
