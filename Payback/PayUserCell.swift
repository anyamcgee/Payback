//
//  PayUserCell.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class PayUserCell : UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScore: UILabel!
    @IBOutlet weak var payButton: UILabel!
    
    var user: User? {
        didSet {
            //updateLabels()
        }
    }
    
    var score: Float? {
        didSet{
            updateLabels()
        }
    }
    
    func updateLabels() {
        if let user = self.user {
            user.fetchIfNecessary().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                self.userName.text = user.name
                let s = self.score!
                self.userScore.text = "\(s)"
                if (s < 0) {
                    self.userScore.textColor = Style.red
                }
                else {
                    self.userScore.textColor = Style.mediumGreen
                }
                return nil;
            })
        }

    }
}
