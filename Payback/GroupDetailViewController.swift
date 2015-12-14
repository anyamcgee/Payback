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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sneakyTableView: UITableView!
    
    var sneakyDelegate: SneakyTableView2Delegate?
    
    var group: Group?
    
    var userInfo: [UserGroupInfo]? = [UserGroupInfo]()
    
    var didAddTransaction: GroupTransaction?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let group = self.group {
            let otherDelegate = SneakyTableView2Delegate(tableView: sneakyTableView, group: group)
            self.sneakyDelegate = otherDelegate
            
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
                    if self.didAddTransaction != nil {
                        Group.recalculateBalances(result, transaction: self.didAddTransaction!)
                    }
                }
                self.tableView.reloadData()
                return nil
            })
        
            
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addUsers:")
            self.navigationItem.rightBarButtonItem = addButton
        }
    }
    
    func addUsers(sender: AnyObject?) {
        self.performSegueWithIdentifier("addUsers", sender: self)
    }
    
    @IBAction func segmentedControlDidChange(sender: AnyObject) {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            self.sneakyTableView.hidden = true
            self.tableView.hidden = false
        } else {
            self.sneakyTableView.hidden = false
            self.tableView.hidden = true
            self.sneakyTableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addUsers" {
            if let vc = segue.destinationViewController as? AddGroupUsersViewController {
                vc.group = self.group
                vc.alreadyExisting = self.userInfo?.map({ return $0.user })
            }
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
