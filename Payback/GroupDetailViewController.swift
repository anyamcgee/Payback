//
//  GroupDetailViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var group: Group?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let group = self.group {
            if let iconName = group.icon {
                self.iconImageView.image = UIImage(named: iconName)
            }
            self.nameLabel.text = group.name
            self.detailLabel.text = group.detail
            self.balanceLabel.text = "\(group.balance)"
            self.authorLabel.text = group.author.name
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
