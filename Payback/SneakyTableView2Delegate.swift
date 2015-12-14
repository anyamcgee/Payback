//
//  SneakyTableView2Delegate.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class SneakyTableView2Delegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var data: [GroupTransaction] = [GroupTransaction]()
    var group: Group
    var tableView: UITableView
    
    init(tableView: UITableView, group: Group) {
        self.tableView = tableView
        self.group = group
        self.data = [GroupTransaction]()
        
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
    }
    
    func getData() {
        
        CurrentUser.sharedInstance.getTransactions(forGroup: self.group, callback: {(result: [GroupTransaction]) -> Void in
                self.data = result
            self.tableView.reloadData()
        })
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= 0 && indexPath.row < self.data.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("transactionCell") as? GroupTransactionTableViewCell {
                cell.amountLabel.text = "\(self.data[indexPath.row].amount)"
                if self.data[indexPath.row].amount >= 0 {
                    cell.amountLabel.textColor = Style.lightGreen
                } else {
                    cell.amountLabel.textColor = Style.red
                }
                cell.userLabel.text = self.data[indexPath.row].user.name
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                formatter.timeStyle = NSDateFormatterStyle.NoStyle
                cell.dateLabel.text = formatter.stringFromDate(self.data[indexPath.row].createdAt)
                cell.reasonLabel.text = self.data[indexPath.row].reason
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
}
