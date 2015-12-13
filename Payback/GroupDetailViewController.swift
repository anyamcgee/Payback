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
    
    var userInfo: [UserGroupInfo]? = [UserGroupInfo]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let group = self.group {
            
            if let iconName = group.icon {
                self.iconImageView.image = UIImage(named: iconName)
            }
            self.nameLabel.text = group.name
            self.detailLabel.text = group.detail
            self.balanceLabel.text = "\(group.balance)"
            if group.balance < 0 {
                balanceLabel.textColor = Style.red
            } else {
                balanceLabel.textColor = Style.mediumGreen
            }
            self.authorLabel.text = group.author.name
            
            let query: IBMQuery = IBMQuery(forClass: "UserGroupInfo")
            query.whereKey("group", equalTo: group)
            query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                if let result = task.result() as? [UserGroupInfo] {
                    self.userInfo = result
                }
                self.tableView.reloadData()
                return nil
            })
        
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userInfo?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.userInfo != nil && indexPath.row >= 0 && indexPath.row < self.userInfo?.count ?? 0 {
            if let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as? UserInfoTableViewCell {
                cell.userInfo = self.userInfo![indexPath.row]
                return cell
            } else {
                let cell = UserInfoTableViewCell()
                cell.userInfo = self.userInfo![indexPath.row]
                return cell
            }
            
        } else {
            return UITableViewCell()
        }
    }
}
