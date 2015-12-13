//
//  TransactionCell.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    // MARK:- Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var transaction: Transaction? {
        didSet {
            updateLabels()
        }
    }
    
    // MARK- Setup
    
    func updateLabels() {
        if let transaction = self.transaction {
            
            if (transaction.toEmail == CurrentUser.sharedInstance.currentUser?.email) {
                self.nameLabel.text = transaction.from.name
            }
            else {
                self.nameLabel.text = transaction.to.name
            }
            self.descriptionLabel.text = transaction.reason
            self.amountLabel.text = "\(transaction.amount)"
        }
    }
    
}

